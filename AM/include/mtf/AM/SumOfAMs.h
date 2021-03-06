#ifndef MTF_SUM_OF_AMS_H
#define MTF_SUM_OF_AMS_H

#include "AppearanceModel.h"

_MTF_BEGIN_NAMESPACE

// Sum of AMs
class SumOfAMs : public AppearanceModel{
public:
	typedef void ParamType;

	SumOfAMs(AppearanceModel *_am1, AppearanceModel *_am2);
	int inputType() const override{
		return am1->inputType() == am2->inputType() ? am1->inputType() : HETEROGENEOUS_INPUT;
	}
	void setCurrImg(const cv::Mat &cv_img) override;

	double getLikelihood() const override{		
		return am1->getLikelihood()*am1_norm_factor + 
			am2->getLikelihood()*am2_norm_factor;
	}

	//-------------------------------initialize functions------------------------------------//

	void initializePixVals(const PtsT& init_pts) override;
	void initializePixGrad(const GradPtsT &warped_offset_pts) override;
	void initializePixGrad(const PtsT &init_pts) override;
	void initializePixHess(const PtsT& init_pts, const HessPtsT &warped_offset_pts) override;
	void initializePixHess(const PtsT &init_pts) override;

	void initializeSimilarity() override;
	void initializeGrad() override;
	void initializeHess() override;

	//-----------------------------------------------------------------------------------//
	//-------------------------------update functions------------------------------------//
	//-----------------------------------------------------------------------------------//

	void updatePixVals(const PtsT& curr_pts) override;

	void updatePixGrad(const GradPtsT &warped_offset_pts) override;
	void updatePixGrad(const PtsT &curr_pts) override;

	void updatePixHess(const PtsT &curr_pts) override;
	void updatePixHess(const PtsT& curr_pts, const HessPtsT &warped_offset_pts) override;

	void updateSimilarity(bool prereq_only = true) override;
	void updateInitGrad() override;
	// nothing is done here since curr_grad is same as and shares memory with  curr_pix_diff
	void updateCurrGrad() override;

	void cmptInitHessian(MatrixXd &init_hessian, const MatrixXd &init_pix_jacobian) override;
	void cmptCurrHessian(MatrixXd &curr_hessian, const MatrixXd &curr_pix_jacobian) override;

	void cmptInitHessian(MatrixXd &init_hessian,	const MatrixXd &init_pix_jacobian,
		const MatrixXd &init_pix_hessian) override;
	void cmptCurrHessian(MatrixXd &curr_hessian, const MatrixXd &curr_pix_jacobian,
		const MatrixXd &curr_pix_hessian) override;

	void cmptSelfHessian(MatrixXd &self_hessian, const MatrixXd &curr_pix_jacobian) override;
	void cmptSelfHessian(MatrixXd &self_hessian, const MatrixXd &curr_pix_jacobian,
		const MatrixXd &curr_pix_hessian) override;

	/*Support for FLANN library*/
	VectorXd curr_feat_vec;
	typedef double ElementType;
	typedef double ResultType;
	double operator()(const double* a, const double* b, size_t size, double worst_dist = -1) const override;
	void updateDistFeat(double* feat_addr) override;
	void initializeDistFeat() override;
	void updateDistFeat() override;
	const double* getDistFeat() override{ return curr_feat_vec.data(); }
	int getDistFeatSize() override;

protected:
	AppearanceModel *am1, *am2;
	double am1_norm_factor, am2_norm_factor;
	int am1_dist_feat_size, am2_dist_feat_size;
};

_MTF_END_NAMESPACE

#endif