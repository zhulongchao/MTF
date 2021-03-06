#include "mtf/SSM/AST.h"
#include "mtf/SSM/SSMEstimator.h"
#include "mtf/Utilities/warpUtils.h"
#include "mtf/Utilities/miscUtils.h"

_MTF_BEGIN_NAMESPACE

ASTParams::ASTParams(const SSMParams *ssm_params,
bool _debug_mode) :
SSMParams(ssm_params),
debug_mode(_debug_mode){}

ASTParams::ASTParams(const ASTParams *params) :
SSMParams(params),
debug_mode(AST_DEBUG_MODE){
	if(params){
		debug_mode = params->debug_mode;
	}
}

AST::AST( const ParamType *_params) :
ProjectiveBase(_params), params(_params){

	printf("\n");
	printf("Using Anisotropic Scaling and Translation SSM with:\n");
	printf("resx: %d\n", resx);
	printf("resy: %d\n", resy);
	printf("debug_mode: %d\n", params.debug_mode);

	name = "ast";
	state_size = 4;
	curr_state.resize(state_size);
}

void AST::setState(const VectorXd &ssm_state){
	validate_ssm_state(ssm_state);
	curr_state = ssm_state;
	getWarpFromState(curr_warp, curr_state);
	curr_pts.noalias() = curr_warp.topRows<2>() * init_pts_hm;
	curr_corners.noalias() = curr_warp.topRows<2>() * init_corners_hm;
}

void AST::compositionalUpdate(const VectorXd& state_update){
	validate_ssm_state(state_update);

	getWarpFromState(warp_update_mat, state_update);
	curr_warp = curr_warp * warp_update_mat;

	getStateFromWarp(curr_state, curr_warp);

	curr_pts.noalias() = curr_warp.topRows<2>() * init_pts_hm;
	curr_corners.noalias() = curr_warp.topRows<2>() * init_corners_hm;
}

void AST::getWarpFromState(Matrix3d &warp_mat,
	const VectorXd& ssm_state){
	validate_ssm_state(ssm_state);

	warp_mat = Matrix3d::Identity();
	warp_mat(0, 0) =  1 + ssm_state(2);
	warp_mat(1, 1) = 1 + ssm_state(3);
	warp_mat(0, 2) = ssm_state(0);
	warp_mat(1, 2) = ssm_state(1);
}

void AST::getStateFromWarp(VectorXd &state_vec,
	const Matrix3d& ast_mat){
	validate_ssm_state(state_vec);
	VALIDATE_AST_WARP(ast_mat);

	state_vec(0) = ast_mat(0, 2);
	state_vec(1) = ast_mat(1, 2);
	state_vec(2) = ast_mat(0, 0) - 1;
	state_vec(3) = ast_mat(1, 1) - 1;
}

void AST::getInitPixGrad(Matrix2Xd &dw_dp, int pt_id) {
	double x = init_pts(0, pt_id);
	double y = init_pts(1, pt_id);
	dw_dp <<
		1, 0, x, 0,
		0, 1, 0, y;
}

void AST::cmptInitPixJacobian(MatrixXd &dI_dp,
	const PixGradT &dI_dx){
	validate_ssm_jacobian(dI_dp, dI_dx);

	int ch_pt_id = 0;
	for(int pt_id = 0; pt_id < n_pts; pt_id++){
		spi_pt_check_mc(spi_mask, pt_id, ch_pt_id);

		double x = init_pts(0, pt_id);
		double y = init_pts(1, pt_id);
		for(int ch_id = 0; ch_id < n_channels; ++ch_id){
			double Ix = dI_dx(ch_pt_id, 0);
			double Iy = dI_dx(ch_pt_id, 1);

			dI_dp(ch_pt_id, 0) = Ix;
			dI_dp(ch_pt_id, 1) = Iy;
			dI_dp(ch_pt_id, 2) = Ix*x;
			dI_dp(ch_pt_id, 3) = Iy*y;
			++ch_pt_id;
		}
	}
}

void AST::cmptApproxPixJacobian(MatrixXd &dI_dp,
	const PixGradT &dI_dx){
	validate_ssm_jacobian(dI_dp, dI_dx);
	double sx_plus_1_inv = 1.0 / (curr_state(2) + 1);
	double sy_plus_1_inv = 1.0 / (curr_state(3) + 1);
	int ch_pt_id = 0;
	for(int pt_id = 0; pt_id < n_pts; ++pt_id){
		spi_pt_check_mc(spi_mask, pt_id, ch_pt_id);

		double x = init_pts(0, pt_id);
		double y = init_pts(1, pt_id);
		for(int ch_id = 0; ch_id < n_channels; ++ch_id){

			double Ix = sx_plus_1_inv * dI_dx(ch_pt_id, 0);
			double Iy = sy_plus_1_inv * dI_dx(ch_pt_id, 1);

			dI_dp(ch_pt_id, 0) = Ix;
			dI_dp(ch_pt_id, 1) = Iy;
			dI_dp(ch_pt_id, 2) = Ix*x;
			dI_dp(ch_pt_id, 3) = Iy*y;
			++ch_pt_id;
		}
	}
}

void AST::cmptWarpedPixJacobian(MatrixXd &dI_dp,
	const PixGradT &dI_dx){
	validate_ssm_jacobian(dI_dp, dI_dx);
	double sx = curr_state(2) + 1;
	double sy = curr_state(3) + 1;

	int ch_pt_id = 0;
	for(int pt_id = 0; pt_id < n_pts; ++pt_id){
		spi_pt_check_mc(spi_mask, pt_id, ch_pt_id);

		double x = init_pts(0, pt_id);
		double y = init_pts(1, pt_id);

		for(int ch_id = 0; ch_id < n_channels; ++ch_id){
			double Ix = sx*dI_dx(ch_pt_id, 0);
			double Iy = sy*dI_dx(ch_pt_id, 1);

			dI_dp(ch_pt_id, 0) = Ix;
			dI_dp(ch_pt_id, 1) = Iy;
			dI_dp(ch_pt_id, 2) = Ix*x;
			dI_dp(ch_pt_id, 3) = Iy*y;
			++ch_pt_id;
		}
	}
}

void AST::cmptInitPixHessian(MatrixXd &d2I_dp2, const PixHessT &d2I_dw2,
	const PixGradT &dI_dw){
	validate_ssm_hessian(d2I_dp2, d2I_dw2, dI_dw);

	int ch_pt_id = 0;
	for(int pt_id = 0; pt_id < n_pts; ++pt_id){
		spi_pt_check_mc(spi_mask, pt_id, ch_pt_id);

		double x = init_pts(0, pt_id);
		double y = init_pts(1, pt_id);
		Matrix24d dw_dp;
		dw_dp <<
			1, 0, x, 0,
			0, 1, 0, y;
		for(int ch_id = 0; ch_id < n_channels; ++ch_id){
			Map<Matrix4d>(d2I_dp2.col(ch_pt_id).data()) = dw_dp.transpose()*Map<const Matrix2d>(d2I_dw2.col(ch_pt_id).data())*dw_dp;
			++ch_pt_id;
		}
	}
}
void AST::cmptWarpedPixHessian(MatrixXd &d2I_dp2, const PixHessT &d2I_dw2,
	const PixGradT &dI_dw) {
	validate_ssm_hessian(d2I_dp2, d2I_dw2, dI_dw);
	double s = curr_state(2) + 1;
	double s2 = s*s;

	int ch_pt_id = 0;
	for(int pt_id = 0; pt_id < n_pts; ++pt_id) {
		spi_pt_check_mc(spi_mask, pt_id, ch_pt_id);

		double x = init_pts(0, pt_id);
		double y = init_pts(1, pt_id);

		Matrix24d dw_dp;
		dw_dp <<
			1, 0, x, 0,
			0, 1, 0, y;

		for(int ch_id = 0; ch_id < n_channels; ++ch_id){
			Map<Matrix4d>(d2I_dp2.col(ch_pt_id).data()) = s2*dw_dp.transpose()*
				Map<const Matrix2d>(d2I_dw2.col(ch_pt_id).data())*dw_dp;
			++ch_pt_id;
		}
	}
}
void AST::estimateWarpFromCorners(VectorXd &state_update, const Matrix24d &in_corners,
	const Matrix24d &out_corners){
	validate_ssm_state(state_update);

	Matrix3d warp_update_mat = utils::computeASTDLT(in_corners, out_corners);
	getStateFromWarp(state_update, warp_update_mat);
}

void AST::estimateWarpFromPts(VectorXd &state_update, vector<uchar> &mask,
	const vector<cv::Point2f> &in_pts, const vector<cv::Point2f> &out_pts,
	const EstimatorParams &est_params){
	assert(state_update.size() == state_size);
	cv::Mat ast_params = estimateAST(in_pts, out_pts, mask, est_params);
	state_update(0) = ast_params.at<double>(0, 0);
	state_update(1) = ast_params.at<double>(0, 1);
	state_update(2) = ast_params.at<double>(0, 2) - 1;
	state_update(3) = ast_params.at<double>(0, 3) - 1;
}

void AST::updateGradPts(double grad_eps){
	double scaled_eps_x = curr_warp(0, 0) * grad_eps;
	double scaled_eps_y = curr_warp(1, 1) * grad_eps;

	for(int pt_id = 0; pt_id < n_pts; ++pt_id){
		spi_pt_check(spi_mask, pt_id);

		grad_pts(0, pt_id) = curr_pts(0, pt_id) + scaled_eps_x;
		grad_pts(1, pt_id) = curr_pts(1, pt_id);

		grad_pts(2, pt_id) = curr_pts(0, pt_id) - scaled_eps_x;
		grad_pts(3, pt_id) = curr_pts(1, pt_id);

		grad_pts(4, pt_id) = curr_pts(0, pt_id);
		grad_pts(5, pt_id) = curr_pts(1, pt_id) + scaled_eps_y;

		grad_pts(6, pt_id) = curr_pts(0, pt_id);
		grad_pts(7, pt_id) = curr_pts(1, pt_id) - scaled_eps_y;
	}
}


void AST::updateHessPts(double hess_eps){
	double scaled_eps_x = curr_warp(0, 0) * hess_eps;
	double scaled_eps_y = curr_warp(1, 1) * hess_eps;
	double scaled_eps_x2 = 2 * scaled_eps_x;
	double scaled_eps_y2 = 2 * scaled_eps_y;


	for(int pt_id = 0; pt_id < n_pts; ++pt_id){

		spi_pt_check(spi_mask, pt_id);

		hess_pts(0, pt_id) = curr_pts(0, pt_id) + scaled_eps_x2;
		hess_pts(1, pt_id) = curr_pts(1, pt_id);

		hess_pts(2, pt_id) = curr_pts(0, pt_id) - scaled_eps_x2;
		hess_pts(3, pt_id) = curr_pts(1, pt_id);

		hess_pts(4, pt_id) = curr_pts(0, pt_id);
		hess_pts(5, pt_id) = curr_pts(1, pt_id) + scaled_eps_y2;

		hess_pts(6, pt_id) = curr_pts(0, pt_id);
		hess_pts(7, pt_id) = curr_pts(1, pt_id) - scaled_eps_y2;

		hess_pts(8, pt_id) = curr_pts(0, pt_id) + scaled_eps_x;
		hess_pts(9, pt_id) = curr_pts(1, pt_id) + scaled_eps_y;

		hess_pts(10, pt_id) = curr_pts(0, pt_id) - scaled_eps_x;
		hess_pts(11, pt_id) = curr_pts(1, pt_id) - scaled_eps_y;

		hess_pts(12, pt_id) = curr_pts(0, pt_id) + scaled_eps_x;
		hess_pts(13, pt_id) = curr_pts(1, pt_id) - scaled_eps_y;

		hess_pts(14, pt_id) = curr_pts(0, pt_id) - scaled_eps_x;
		hess_pts(15, pt_id) = curr_pts(1, pt_id) + scaled_eps_y;
	}
}

void AST::applyWarpToCorners(Matrix24d &warped_corners, const Matrix24d &orig_corners,
	const VectorXd &state_update){

	warped_corners.row(0) = (orig_corners.row(0).array() * (state_update(2) + 1)) + state_update(0);
	warped_corners.row(1) = (orig_corners.row(1).array() * (state_update(3) + 1)) + state_update(1);
}
void AST::applyWarpToPts(Matrix2Xd &warped_pts, const Matrix2Xd &orig_pts,
	const VectorXd &state_update){
	warped_pts.row(0) = (orig_pts.row(0).array() * (state_update(2) + 1)) + state_update(0);
	warped_pts.row(1) = (orig_pts.row(1).array() * (state_update(3) + 1)) + state_update(1);
}

_MTF_END_NAMESPACE

