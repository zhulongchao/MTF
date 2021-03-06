#ifndef MTF_CHOMOGRAPHY_H
#define MTF_CHOMOGRAPHY_H

#define CBH_NORMALIZED_BASIS false
#define CBH_GRAD_EPS 1e-8
#define CBH_DEBUG_MODE 0

#include "ProjectiveBase.h"

_MTF_BEGIN_NAMESPACE

struct CBHParams : SSMParams{
	// compute all warps w.r.t. the initial object bounding box rather than the unit square 
	// centered at the origin
	bool normalized_init;
	double grad_eps;
	bool debug_mode;

	CBHParams(const SSMParams *ssm_params,
		bool _normalized_init, double _grad_eps, bool _debug_mode);
	CBHParams(const CBHParams *params = nullptr);
};
//! Corner Based Homography
class CBH : public ProjectiveBase{
public:

	typedef CBHParams ParamType;

	using ProjectiveBase::setCorners;

	CBH( const ParamType *params_in = nullptr);

	void setCorners(const Matrix24d &corners) override;
	void compositionalUpdate(const VectorXd& state_update) override;

	void cmptInitPixJacobian(MatrixXd &jacobian_prod, const PixGradT &am_jacobian) override;
	void cmptWarpedPixJacobian(MatrixXd &dI_dp, const PixGradT &dI_dw) override;
	void cmptPixJacobian(MatrixXd &jacobian_prod, const PixGradT &am_jacobian) override;
	void cmptApproxPixJacobian(MatrixXd &jacobian_prod,
		const PixGradT &pix_jacobian) override;

	void estimateWarpFromCorners(VectorXd &state_update, const Matrix24d &in_corners,
		const Matrix24d &out_corners) override;
	void estimateWarpFromPts(VectorXd &state_update, vector<uchar> &mask,
		const vector<cv::Point2f> &in_pts, const vector<cv::Point2f> &out_pts,
		const EstimatorParams &est_params) override;

	void invertState(VectorXd& inv_state, const VectorXd& state) override;
	void getInitPixGrad(Matrix2Xd &ssm_grad, int pt_id) override{
		getPixGrad(ssm_grad, pt_id, init_pts, init_corners);
	}
	void getCurrPixGrad(Matrix2Xd &ssm_grad, int pt_id) override{
		getPixGrad(ssm_grad, pt_id, curr_pts, curr_corners);
	}

	void getWarpFromState(Matrix3d &warp_mat, const VectorXd& ssm_state) override;
	void getStateFromWarp(VectorXd &state_vec, const Matrix3d& warp_mat) override;

private:

	ParamType params;

	Matrix3d warp_update_mat;
	Matrix3d warp_mat;
	RowVectorXdM hom_den;
	MatrixXd dw_dp_0, dw_dp_t;

	Matrix24d inc_corners, dec_corners;
	Matrix2Xd inc_pts, dec_pts;
	Matrix3d inc_warp, dec_warp;

	Matrix24d updated_corners;

	void computeJacobian(MatrixXd &jacobian, Matrix24d &basis_corners,
		Matrix3Xd &basis_pts_hm);
	void getPixGrad(Matrix2Xd &ssm_grad, int pt_id,	const PtsT &pts, const CornersT &corners);

};

_MTF_END_NAMESPACE

#endif
