#ifndef MTF_CCRE_H
#define MTF_CCRE_H

//! OpenMP scheduler
#ifndef CCRE_OMP_SCHD
#define CCRE_OMP_SCHD auto
#endif

#define CCRE_N_BINS 8
#define CCRE_PRE_SEED 10
#define CCRE_POU false
#define CCRE_SYMMETRICAL_GRAD false
#define CCRE_N_BLOCKS 0
#define CCRE_DEBUG_MODE false

#include "AppearanceModel.h"

_MTF_BEGIN_NAMESPACE

struct CCREParams : AMParams{

	//! no. of bins in the histograms used internally - dimensionality of the CCRE error vector will be n_bins * n_bins; 
	//! if partition_of_unity is enabled, this should be 2 more than the desired no. of bins (w.r.t normalized pixel range)
	//! since the actual range within which the pixel values are normalized is 2 less than this value to avoid
	//!	boundary conditions while computing the contribution of each pixel to different bins by ensuring that pixels with the maximum and
	//! minimum values contribute to all 4 bins required by the bspl function of degree 3 used here;
	int n_bins;
	//! decides whether the partition of unity constraint has to be strictly observed for border bins;
	//! if enabled, the pixel values will be normalized in the range [1, n_bins-2] so each pixel contributes to all 4 bins
	bool partition_of_unity;
	//! initial value with which each bin of the joint histogram is pre-seeded
	//! to avoid numerical instabilities due to empty or near empty bins (caused e.g. by having to assume log(0) = 0 for empty bins) 
	double pre_seed;
	// decides if the model is to be symmetrical 
	// with respect to initial and current pixel values
	// as far as the gradient and hessian computations are concerned;	
	bool symmetrical_grad;
	// no. of blocks in which to divide pixel level computations to get better performance 
	// with parallelization libraries like TBB and OpenMP; only matters if these are enabled during compilation;
	// if set to 0 (default), this is set equal to the no. of pixels so that each block contains a single pixel
	int n_blocks;	

	bool debug_mode; 
	//! value constructor
	CCREParams(const AMParams *am_params,
		int _n_bins, bool _partition_of_unity,
		double _pre_seed, bool _symmetrical_grad,
		int _n_blocks, 
		bool _debug_mode);
	//! default and copy constructor
	CCREParams(const CCREParams *params = nullptr);
};

//! Cross Cumulative Residual Entropy
class CCRE : public AppearanceModel{

public:

	typedef CCREParams ParamType;	

	CCRE(const ParamType *ccre_params = nullptr, int _n_channels = 1);

	double getLikelihood() const override{
		double d = (likelihood_numr / f) - 1;
		return exp(-params.likelihood_alpha * d*d);
	}

	bool isSymmetrical() const override{ return false; }

	void initializeSimilarity() override;
	void initializeGrad() override;
	void initializeHess() override;

	void updateSimilarity(bool prereq_only = 1) override;
	void updateInitGrad() override;
	void updateCurrGrad() override;

	void cmptInitHessian(MatrixXd &hessian, const MatrixXd &curr_pix_jacobian) override;
	void cmptCurrHessian(MatrixXd &hessian, const MatrixXd &curr_pix_jacobian) override;

	void cmptInitHessian(MatrixXd &init_hessian, const MatrixXd &init_pix_jacobian,
		const MatrixXd &init_pix_hessian) override;
	void cmptCurrHessian(MatrixXd &curr_hessian, const MatrixXd &curr_pix_jacobian,
		const MatrixXd &curr_pix_hessian) override;

	void cmptSelfHessian(MatrixXd &self_hessian, const MatrixXd &curr_pix_jacobian) override;
	void cmptSelfHessian(MatrixXd &self_hessian, const MatrixXd &curr_pix_jacobian,
		const MatrixXd &curr_pix_hessian) override;

	//-----------------------------------functor support-----------------------------------//
	int feat_size;
	VectorXd feat_vec;

	typedef double ElementType;
	typedef double ResultType;

	void initializeDistFeat() override{
		feat_vec.resize(feat_size);
	}
	void updateDistFeat() override{
		updateDistFeat(feat_vec.data());
	}
	const double* getDistFeat() override{ return feat_vec.data(); }
	void updateDistFeat(double* feat_addr) override;
	double operator()(const double* hist1_mat_addr, const double* hist2_mat_addr,
		size_t hist_mat_size, double worst_dist = -1) const override;
	int getDistFeatSize() override{ return feat_size; }

protected:
	ParamType params;

	double max_similarity, likelihood_numr;

	//! value with which to preseed the individual histograms
	double hist_pre_seed;
	//! multiplicative factor for normalizing histograms
	double hist_norm_mult;
	int joint_hist_size;

	double log_hist_norm_mult;

	// let A = joint_hist_size = n_bins*n_bins and N = n_pix = no. of pixels
	//! n_bins x n_bins joint histograms; 
	VectorXd init_hist, curr_hist;
	VectorXd init_cum_hist, curr_cum_hist;
	MatrixXd init_hist_mat, curr_hist_mat;
	MatrixXd init_cum_hist_mat, curr_cum_hist_mat;
	MatrixXd cum_joint_hist;

	//! n_bins X N gradients of the marginal histograms w.r.t. pixel values
	MatrixXd init_hist_grad, curr_hist_grad;
	MatrixXd init_cum_hist_grad, curr_cum_hist_grad;
	MatrixXd init_hist_hess, curr_hist_hess;
	MatrixXd init_cum_hist_hess, curr_cum_hist_hess;

	//! (n_bins*n_bins) X N gradients of the (flattened) current joint histogram w.r.t. initial and current pixel values
	MatrixXd init_cum_joint_hist_grad, curr_cum_joint_hist_grad;

	MatrixXd ccre_log_term;
	MatrixXd init_hess_factor, cum_hess_factor;

	MatrixXd init_hist_grad_ratio, cum_hist_grad_ratio;
	MatrixXd init_hist_hess_ratio, cum_hist_hess_ratio;

	VectorXd init_hist_log, curr_hist_log;
	VectorXd init_cum_hist_log, curr_cum_hist_log;
	MatrixXd cum_joint_hist_log;

	VectorXd cum_joint_hist_sum;

	MatrixXd self_cum_joint_hist, self_cum_joint_hist_log;
	MatrixXd self_ccre_log_term;

	//! only used internally to increase speed by offlining as many computations as possible;
	MatrixX2i _std_bspl_ids;
	MatrixX2i _init_bspl_ids;
	MatrixX2i _curr_bspl_ids;
	MatrixXi _linear_idx, _linear_idx2;

	MatrixX2i block_extents;
	char *log_fname;
	char *time_fname;

	void updateSymSimilarity(bool prereq_only);
	void updateSymInitGrad();
	void cmptSymInitHessian(MatrixXd &hessian, const MatrixXd &curr_pix_jacobian);
	void cmptCumSelfHist();

};

_MTF_END_NAMESPACE

#endif