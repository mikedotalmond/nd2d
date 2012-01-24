package de.nulldesign.nd2d.geom {
	
	/**
	 * ...
	 * @author Mike Almond - https://github.com/mikedotalmond
	 */
	
	import de.nulldesign.nd2d.utils.PolyUtils;
	import de.nulldesign.nd2d.utils.TextureHelper;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import net.nicoptere.delaunay.Delaunay;
	import net.nicoptere.delaunay.DelaunayTriangle;
	
	public final class PolygonData {
		public var alignedAboutCentroid			:Boolean;
		public var triangleMeshHasCentralVertex	:Boolean;
		public var bounds						:Rectangle;
		public var triangles					:Vector.<DelaunayTriangle>;
		public var vertices						:Vector.<Vector3D>;
		
		 /**
		  * 
		  * @param	vertices		List of Vector3Ds describing a convex polygon, or if constructHull==true, a point cloud to be formed into a convex polygon
		  * @param	constructHull	Set true for most cases - //NOTE: is the option needed?
		  * @param	triangleMeshHasCentralVertex - if set a central vertex is included in the final triangles (not the vertices), 
		  * 		It sorts out the eventual UV mapping without breaking Nape Polygon construction - polygons for nape must have no interior points)
		  */
		public function PolygonData(vertices:Vector.<Vector3D>, constructHull:Boolean = true, addCentralVertexToTriangleMesh:Boolean = true) {
			if (vertices.length < 3) {
				trace("Too few vertices, that's no polygon!");
				return;
			}
			
			this.vertices 					= constructHull ? PolyUtils.convexHull(vertices) : vertices;
			triangleMeshHasCentralVertex 	= addCentralVertexToTriangleMesh;
			init();	
		}
		
		private function init():void {
			
			var t:Vector.<Vector3D> = vertices.concat();
			
			t.fixed = true;
			const n:uint = t.length;
			
			t.sort(PolyUtils.sortVector3DByY);
			const minY	:Number = t[0].y
			const maxY	:Number = t[n - 1].y;
			
			t.sort(PolyUtils.sortVector3DByX);
			const minX	:Number = t[0].x
			const maxX	:Number = t[n - 1].x;
			
			const dx	:Number = maxX - minX; // width
			const dy	:Number = maxY - minY; // height
			const hdx	:Number = dx / 2;
			const hdy	:Number = dy / 2;
			
			bounds = new Rectangle(minX, minY, dx, dy); // rect encompassing the original path bonuds
			
			// get centre-of-mass (centroid)
			const cnt:Vector3D = PolyUtils.getCentroid(vertices);
			vertices.map(function(item:Vector3D, index:int, vector:Vector.<Vector3D>):void {
				item.x -= cnt.x;
				item.y -= cnt.y;
			});
			
			t = vertices.concat();
			
			if (triangleMeshHasCentralVertex) { // ? add central vetex
				t.unshift(new Vector3D(0,0,0)); // we're already aligned with centroid at 0,0 - so add the central vertex at 0,0 too
			}
			
			t.fixed = true;
			// triangulate
			this.triangles = Delaunay.Triangulate(t);
		}
	}
}