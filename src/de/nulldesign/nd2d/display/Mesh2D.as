package de.nulldesign.nd2d.display {
	
	/**
	 * ...
	 * @author Mike Almond
	 */
	
	import de.nulldesign.nd2d.display.Camera2D;
	import de.nulldesign.nd2d.display.Node2D;
	import de.nulldesign.nd2d.geom.Face;
	import de.nulldesign.nd2d.materials.AMaterial;
	import de.nulldesign.nd2d.materials.AMesh2DMaterial;
	import de.nulldesign.nd2d.materials.BlendModePresets;
	import de.nulldesign.nd2d.materials.Mesh2DColorMaterial;
	import de.nulldesign.nd2d.materials.Mesh2DTextureMaterial;
	import de.nulldesign.nd2d.materials.MeshData;
	import de.nulldesign.nd2d.materials.texture.Texture2D;
	import de.nulldesign.nd2d.utils.TextureHelper;
	
	import flash.display3D.Context3D;
	import flash.geom.Vector3D;
	
	import net.nicoptere.delaunay.Delaunay;
	
	
	public final class Mesh2D extends Node2D {
		
		static public function fromPointCloud(points:Vector.<Vector3D>, textureObject:Texture2D=null, colour:uint=0):Mesh2D {
			return new Mesh2D(TextureHelper.generateMeshFromDelaunayTriangulation(Delaunay.Triangulate(points)), textureObject, colour);
		}
		
		static public function fromVertices(vertices:Vector.<Vector3D>, textureObject:Texture2D=null, colour:uint=0):Mesh2D {
			return new Mesh2D(TextureHelper.generateMeshFromVertices(vertices), textureObject, colour);
		}
		
		static public function circle(radius:Number, subdivisions:uint, textureObject:Texture2D=null, colour:uint=0):Vector.<Face> {
			return null;
		}
		
		public var faceList	:Vector.<Face>;
		public var material	:AMesh2DMaterial;
		public var texture	:Texture2D;

		public function Mesh2D(meshData:MeshData, textureObject:Texture2D = null, colour:uint=0) {
			_width 			= meshData.width;
			_height 		= meshData.height;
			this.faceList 	= meshData.faceList;
			blendMode 		= BlendModePresets.NORMAL_NO_PREMULTIPLIED_ALPHA;
			
			if(textureObject) {
				setMaterial(new Mesh2DTextureMaterial(_width, _height));
				setTexture(textureObject);
			} else {
				setMaterial(new Mesh2DColorMaterial(_width, _height, colour));				
			}
		}
		
		/**
		 * The texture object
		 * @param Texture2D
		 */
		public function setTexture(value:Texture2D):void {
			
			if(texture) {
				texture.dispose();
			}
			
			texture = value;
			
			if(texture) {
				hasPremultipliedAlphaTexture = texture.hasPremultipliedAlpha;
				blendMode = texture.hasPremultipliedAlpha ? BlendModePresets.NORMAL_PREMULTIPLIED_ALPHA : BlendModePresets.NORMAL_NO_PREMULTIPLIED_ALPHA;
			}
		}
		
		public function setMaterial(value:AMesh2DMaterial):void {
			
			if(material) {
				material.dispose();
			}

			this.material = value;
		}
		
		
		override public function get numTris():uint {
			return faceList.length;
		}

		override public function get drawCalls():uint {
			return material.drawCalls;
		}
		
		override public function handleDeviceLoss():void {
			super.handleDeviceLoss();
			if(material) material.handleDeviceLoss();
		}
		
		override protected function draw(context:Context3D, camera:Camera2D):void {
			
			material.blendMode = blendMode;
			material.modelMatrix = worldModelMatrix;
			material.viewProjectionMatrix = camera.getViewProjectionMatrix(false);
			
			if (material as Mesh2DTextureMaterial) {
				(material as Mesh2DTextureMaterial).colorTransform 	= combinedColorTransform;
				if(texture) (material as Mesh2DTextureMaterial).texture = texture;
			}
			
			material.render(context, faceList, 0, faceList.length);
		}
		
		override public function dispose():void {
			if(material) {
				material.dispose();
				material = null;
			}
			
			if (texture) {
				texture.dispose();
				texture = null;
			}
			
			faceList = null;
			
			super.dispose();
		}
		
	}
}
