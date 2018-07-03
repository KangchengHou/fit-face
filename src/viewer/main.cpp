#include "biharmonic_precompute.h"
#include "biharmonic_solve.h"
#include "MorphModel.h"
#include <igl/min_quad_with_fixed.h>
#include <igl/read_triangle_mesh.h>
#include <igl/viewer/Viewer.h>
#include <igl/project.h>
#include <igl/unproject.h>
#include <igl/snap_points.h>
#include <igl/unproject_onto_mesh.h>
#include <Eigen/Core>
#include <iostream>
#include <igl/writeOBJ.h>

using namespace std;



// stores the current state
struct State
{
	// Rest and transformed control points
	Eigen::MatrixXd CV, CU;
	bool placing_handles = true;
} s;
int laplacian(int argc, char *argv[]);

int main(int argc, char* argv[]) {
	laplacian(argc, argv);
	//std::string root = "C:/Users/david/Desktop/swapface/metadata/basel_face_cpp/";
	//std::string coef_root = "C:/Users/david/Desktop/swapface/data/obama/imgs/";
	//MorphModel morph_model(root);
	//int cnt = 1;
	//Eigen::MatrixXd id_coef(199, 1); id_coef.setZero();
	//Eigen::MatrixXd exp_coef(100, 1); exp_coef.setZero();
	//MatrixXd V = morph_model.get_verts(id_coef, exp_coef);
	//MatrixXi F = morph_model.get_faces();

	//id_coef = MorphModel::read_mat(coef_root + "1.coef").topRows(199);
	//igl::viewer::Viewer viewer;
	//viewer.callback_pre_draw =
	//	[&](igl::viewer::Viewer &)->bool
	//{
	//	if (viewer.core.is_animating)
	//	{
	//		
	//		// read data, 
	//		MatrixXd coef = MorphModel::read_mat(coef_root + std::to_string(cnt) + ".coef");
	//		cnt = cnt + 1;
	//		if (cnt > 303) cnt = 1;
	//		//MatrixXd id_coef = coef.topRows(199);
	//		MatrixXd exp_coef = coef.bottomRows(100);
	//		V = morph_model.get_verts(id_coef, exp_coef);
	//		viewer.data.set_vertices(V);
	//		
	//	}
	//	return false;
	//};
	//viewer.data.set_mesh(V, F);

	//// do some animating
	//viewer.core.show_lines = false;
	//viewer.core.is_animating = true;
	//viewer.core.animation_max_fps = 15.0;
	//viewer.data.face_based = true;
	//viewer.launch();
	//

	////igl::writeOBJ(root + "test.obj", V, F);

	//return 0;
}


int laplacian(int argc, char *argv[])
{


  Eigen::MatrixXd V,U;
  Eigen::MatrixXi F;
  long sel = -1;
  Eigen::RowVector3f last_mouse;
  igl::min_quad_with_fixed_data<double> biharmonic_data;

  // Load input meshes
  std::string input_root = "C:/Users/david/Desktop/swapface/data/obama3/";
  igl::readOBJ(input_root + "model.obj", V, F);
  //igl::read_triangle_mesh(
  //  (argc>1?argv[1]:"C:/Users/david/Desktop/swapface/data/obama3/model.obj"),V,F);
  U = V;
  igl::viewer::Viewer viewer;
  std::cout<<R"(
	[click]  To place new control point
	[drag]   To move control point
	[space]  Toggle whether placing control points or deforming
	[s]		 Save mesh
	)";
  enum Method
  {
    BIHARMONIC = 0,
    NUM_METHODS = 1,
  } method = BIHARMONIC;

  const auto & update = [&]()
  {
    // predefined colors
    const Eigen::RowVector3d orange(1.0,0.7,0.2);
    const Eigen::RowVector3d yellow(1.0,0.9,0.2);
    const Eigen::RowVector3d blue(0.2,0.3,0.8);
    const Eigen::RowVector3d green(0.2,0.6,0.3);
    if(s.placing_handles)
    {
      viewer.data.set_vertices(V);
      viewer.data.set_colors(blue);
      viewer.data.set_points(s.CV,orange);
    }else
    {
      // SOLVE FOR DEFORMATION
      switch(method)
      {
        default:
        case BIHARMONIC:
        {
          Eigen::MatrixXd D;
          biharmonic_solve(biharmonic_data,s.CU-s.CV,D);
          U = V+D;
          break;
        }
      }
      viewer.data.set_vertices(U);
      viewer.data.set_colors(orange);
      viewer.data.set_points(s.CU,blue);
    }
    viewer.data.compute_normals();
  };

  viewer.callback_mouse_down = 
    [&](igl::viewer::Viewer&, int, int)->bool
  {
    last_mouse = Eigen::RowVector3f(
      viewer.current_mouse_x,viewer.core.viewport(3)-viewer.current_mouse_y,0);
	
	// placing a handle
    if(s.placing_handles)
    {
      // Find closest point on mesh to mouse position
      int fid;
      Eigen::Vector3f bary;
      if(igl::unproject_onto_mesh(
        last_mouse.head(2),
        viewer.core.view * viewer.core.model,
        viewer.core.proj, 
        viewer.core.viewport, 
        V, F, 
        fid, bary))
      {
        long c;
        bary.maxCoeff(&c);
        Eigen::RowVector3d new_c = V.row(F(fid,c));
        if(s.CV.size()==0 || (s.CV.rowwise()-new_c).rowwise().norm().minCoeff() > 0)
        {
          s.CV.conservativeResize(s.CV.rows()+1,3);
          // Snap to closest vertex on hit face
          s.CV.row(s.CV.rows()-1) = new_c;
          update();
          return true;
        }
      }
    }else
    {
      // Move closest control point
      Eigen::MatrixXf CP;
      igl::project(
        Eigen::MatrixXf(s.CU.cast<float>()),
        viewer.core.view * viewer.core.model, 
        viewer.core.proj, viewer.core.viewport, CP);
      Eigen::VectorXf D = (CP.rowwise()-last_mouse).rowwise().norm();
      sel = (D.minCoeff(&sel) < 30)?sel:-1;
      if(sel != -1)
      {
        last_mouse(2) = CP(sel,2);
        update();
        return true;
      }
    }
    return false;
  };

  viewer.callback_mouse_move = [&](igl::viewer::Viewer &, int,int)->bool
  {
    if(sel!=-1)
    {
      Eigen::RowVector3f drag_mouse(
        viewer.current_mouse_x,
        viewer.core.viewport(3) - viewer.current_mouse_y,
        last_mouse(2));
      Eigen::RowVector3f drag_scene,last_scene;
      igl::unproject(
        drag_mouse,
        viewer.core.view*viewer.core.model,
        viewer.core.proj,
        viewer.core.viewport,
        drag_scene);
      igl::unproject(
        last_mouse,
        viewer.core.view*viewer.core.model,
        viewer.core.proj,
        viewer.core.viewport,
        last_scene);
      s.CU.row(sel) += (drag_scene-last_scene).cast<double>();
      last_mouse = drag_mouse;
      update();
      return true;
    }
    return false;
  };
  viewer.callback_mouse_up = [&](igl::viewer::Viewer&, int, int)->bool
  {
    sel = -1;
    return false;
  };
  viewer.callback_key_pressed = 
    [&](igl::viewer::Viewer &, unsigned int key, int mod)
  {
    switch(key)
    {
      case ' ':
        s.placing_handles ^= 1;
        if(!s.placing_handles && s.CV.rows()>0)
        {
          // Switching to deformation mode
          s.CU = s.CV;
          Eigen::VectorXi b;
          igl::snap_points(s.CV,V,b);
          // PRECOMPUTATION FOR DEFORMATION
          biharmonic_precompute(V,F,b,biharmonic_data);
        }
        break;
	  case 's':
		  // save model
		  igl::writeOBJ(input_root + "deform_model.obj", viewer.data.V, viewer.data.F);
		  break;
		  
      default:
        return false;
    }
    update();
    return true;
  };


  viewer.callback_pre_draw = 
    [&](igl::viewer::Viewer &)->bool
  {
    if(viewer.core.is_animating && !s.placing_handles)
    {
      update();
    }
    return false;
  };
  viewer.data.set_mesh(V,F);
  viewer.core.show_lines = false;
  viewer.core.is_animating = true;
  viewer.data.face_based = true;
  update();
  viewer.launch();
  return EXIT_SUCCESS;
}

