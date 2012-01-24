package de.nulldesign.nd2d.display {
	
	import de.nulldesign.nd2d.display.Camera2D;
	import de.nulldesign.nd2d.display.Node2D;
	import de.nulldesign.nd2d.geom.Face;
	import de.nulldesign.nd2d.geom.PolygonData;
	import de.nulldesign.nd2d.materials.APolygon2DMaterial;
	import de.nulldesign.nd2d.materials.BlendModePresets;
	import de.nulldesign.nd2d.materials.Polygon2DColorMaterial;
	import de.nulldesign.nd2d.materials.Polygon2DTextureMaterial;
	import de.nulldesign.nd2d.materials.texture.Texture2D;
	import de.nulldesign.nd2d.utils.TextureHelper;
	import flash.geom.Vector3D;
	
	import flash.display3D.Context3D;
	
	/**
	 * ...
	 * @author Mike Almond - https://github.com/mikedotalmond
	 *
	 * Convex polygons for nd2d
	 * Create a new Polygon2D with some PolygonData from a custom vertex list or point-cloud, 
	 * or use the static Polygon2D.regularPolygon, Polygon2D.circle helpers
	 */
	public class Polygon2D extends Node2D {
		
		/**
		 * Create a regular polygon (pent,hex,sept,dodeca etc..)
		 * @param	radius								Radius of created polygon
		 * @param	edgeCount							Polygon edge count
		 * @param	addCentralVertexToTriangleMesh		(always leave true..? is the option needed?)
		 * @return	The PolygonData to construct your Polygon2D with.
		 */
		public static function regularPolygon(radius:Number, edgeCount:uint = 5, addCentralVertexToTriangleMesh:Boolean = false):PolygonData {
			if (edgeCount < 5) {
				if (edgeCount < 4) {
					throw new ArgumentError(edgeCount + "... isn't many edges is it? I can't create a Polygon2D from that.");
				} else {
					throw new ArgumentError("Only 4 edges? I can't create a Polygon2D from that. Consider using a Quad2D instead.");
				}
				return null;
			}
			
			const t	:Number = (Math.PI * 2) / edgeCount;
			var n	:uint 	= edgeCount + 1;
			var v	:Vector.<Vector3D> = new Vector.<Vector3D>();
			var p	:Vector3D;
			
			// sweep around the circle described by the radius and create new vertices at each angle increment (where angle increment = 2Pi/edgeCount)
			while (--n) v.unshift(new Vector3D(Math.sin(Math.PI + n * t) * radius, Math.cos(Math.PI + n * t) * radius));
			v.fixed = true;
			
			// creating a hull so the shape gets aligned correcly, then adding in a central vertex at 0,0 for triangles to radiate from
			return new PolygonData(v, true, addCentralVertexToTriangleMesh);
		}
		
		/**
		 * Just a shortcut to regularPolygon with a default of 32 subdivisions, more of a pointer to how to create circles I guess..
		 * @param	radius
		 * @param	subdivisions
		 * @param	textureObject
		 * @param	colour
		 * @return
		 */
		public static function circle(radius:Number, subdivisions:uint = 32):PolygonData {
			return Polygon2D.regularPolygon(radius, subdivisions, true);
		}
		
		
		
		public var faceList		:Vector.<Face>;
		public var material		:APolygon2DMaterial;
		public var texture		:Texture2D;
		public var polygonData	:PolygonData;
		
		public function Polygon2D(polygonData:PolygonData, textureObject:Texture2D = null, colour:uint=0) {
			
			this.polygonData 	= polygonData;
			_width 				= polygonData.bounds.width;
			_height 			= polygonData.bounds.height;
			faceList 			= TextureHelper.generateMeshFaceListFromPolygonData(polygonData);
			blendMode 			= BlendModePresets.NORMAL_NO_PREMULTIPLIED_ALPHA;
			
			if(textureObject) {
				setMaterial(new Polygon2DTextureMaterial(_width, _height));
				setTexture(textureObject);
			} else {
				setMaterial(new Polygon2DColorMaterial(_width, _height, colour));				
			}
			
			x = polygonData.bounds.x;
			y = polygonData.bounds.y;
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
		
		public function setMaterial(value:APolygon2DMaterial):void {
			
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
			
			if (material as Polygon2DTextureMaterial) {
				(material as Polygon2DTextureMaterial).colorTransform 	= combinedColorTransform;
				if(texture) (material as Polygon2DTextureMaterial).texture = texture;
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
