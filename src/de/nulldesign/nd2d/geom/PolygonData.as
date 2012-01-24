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
		
		public var bounds			:Rectangle;
		public var triangles		:Vector.<DelaunayTriangle>;
		public var vertices			:Vector.<Vector3D>;
		
		/**
		 * 
		 * @param	vertices	-	List of Vector3Ds describing a convex polygon, or if constructHull==true, a point cloud to be formed into a convex polygon
		 */
		public function PolygonData(vertices:Vector.<Vector3D>, constructHull:Boolean = true) {
			if (vertices.length < 3) {
				trace("Too few vertices, that's no polygon!");
				return;
			}
			
			this.vertices = constructHull ? PolyUtils.convexHull(vertices) : vertices;
			
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
			
			bounds = new Rectangle(minX, minY, dx, dy);
			
			// offset poly points to move the polygone centred about 0,0
			vertices.map(function(item:Vector3D, index:int, vector:Vector.<Vector3D>):void {
				item.x -= hdx;
				item.y -= hdy;
			});
			
			// get centre-of-mass (centroid)
			const cnt:Vector3D = PolyUtils.getCentroid(vertices);
			vertices.map(function(item:Vector3D, index:int, vector:Vector.<Vector3D>):void {
				item.x -= cnt.x;
				item.y -= cnt.y;
			});
			
			// triangulate
			this.triangles = Delaunay.Triangulate(vertices);
		}
	}
}