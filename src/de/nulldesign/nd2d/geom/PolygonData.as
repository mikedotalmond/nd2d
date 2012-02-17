package de.nulldesign.nd2d.geom {
	
	/**
	 * ...
	 * @author Mike Almond - https://github.com/mikedotalmond
	 */
	
	import de.nulldesign.nd2d.utils.PolyUtils;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import nape.geom.Vec2;
	import nape.geom.Vec2List;
	import nape.phys.Body;
	import nape.shape.ShapeList;
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
		  * @param	addCentralVertexToTriangleMesh - if set a central vertex is included in the final triangles (not the vertices), 
		  * 		It sorts out the eventual UV mapping without breaking Nape Polygon construction - polygons for nape must have no interior points)
		  */
		public function PolygonData(vertices:Vector.<Vector3D>, constructHull:Boolean = true, addCentralVertexToTriangleMesh:Boolean = true, useBoundsForCentroid:Boolean = false) {
			if (vertices == null) return;
			if (vertices.length < 3) {
				throw new RangeError("Too few vertices, that's no polygon!");
				return;
			}
			
			this.vertices 					= constructHull ? PolyUtils.convexHull(vertices) : vertices;
			triangleMeshHasCentralVertex 	= addCentralVertexToTriangleMesh;
			init(useBoundsForCentroid);	
		}
		
		private function init(useBoundsForCentroid:Boolean):void {
			
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
			const cnt:Vector3D = useBoundsForCentroid ? new Vector3D(bounds.x + (bounds.width / 2), bounds.y + (bounds.height / 2)) : PolyUtils.getCentroid(vertices);
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
			//trace(triangles);
		}
		
		static public function fromBodyShapes(bodies:Vector.<Body>, width:int, height:int, offset:Vec2):PolygonData {
			var bodyIndex		:int = -1;
			var numBodies		:int = bodies.length;
			var shapeIndex		:int;
			var numShapes		:int;
			var shapes			:ShapeList;
			var verts			:Vector.<Vector3D>;
			var triangles		:Vector.<DelaunayTriangle>	= new Vector.<DelaunayTriangle>();
			
			var polyWorldVerts	:Vec2List;
			var pCount			:int;
			var pIndex			:int;
			
			var polygonData:PolygonData 				= new PolygonData(null);
			polygonData.bounds 							= new Rectangle(offset.x, offset.y, width, height);
			polygonData.alignedAboutCentroid 			= true;
			polygonData.triangleMeshHasCentralVertex 	= false;
			polygonData.vertices 						= null;
			
			while (++bodyIndex < numBodies) {
				shapes 			= bodies[bodyIndex].shapes;
				numShapes 		= shapes.length;
				shapeIndex 		= -1;
				while (++shapeIndex < numShapes) {
					verts 			= new Vector.<Vector3D>(shapes.at(shapeIndex).castPolygon.worldVerts.length, true);
					polyWorldVerts	= shapes.at(shapeIndex).castPolygon.worldVerts;
					pCount			= polyWorldVerts.length;
					pIndex			= -1;
					while (++pIndex < pCount) {
						verts[pIndex] = new Vector3D(polyWorldVerts.at(pIndex).x, polyWorldVerts.at(pIndex).y);
					}
					verts.fixed = true;
					triangles 	= triangles.concat(Delaunay.Triangulate(verts));
				}
			}
			
			triangles.fixed 		= true;
			polygonData.triangles 	= triangles;
			
			return polygonData;
		}
	}
}