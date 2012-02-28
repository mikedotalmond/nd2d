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
	
	public final class PolygonData {
		
		public var alignedAboutCentroid			:Boolean;
		public var triangleMeshHasCentralVertex	:Boolean;
		public var bounds						:Rectangle;
		public var triangleVertices				:Vector.<Vertex>;
		public var polygonVertices				:Vector.<Vertex>;
		
		 /**
		  * 
		  * @param	vertices		List of Vector3Ds describing a convex polygon, or if constructHull==true, a point cloud to be formed into a convex polygon
		  * @param	constructHull	Set true for most cases - //NOTE: is the option needed?
		  * @param	addCentralVertexToTriangleMesh - if set a central vertex is included in the final triangles (not the vertices), 
		  * 		It sorts out the eventual UV mapping without breaking Nape Polygon construction - polygons for nape must have no interior points)
		  */
		public function PolygonData(vertices:Vector.<Vertex>, constructHull:Boolean = true, addCentralVertexToTriangleMesh:Boolean = false, useBoundsForCentroid:Boolean = false) {
			if (vertices == null) return;
			if (vertices.length < 3) {
				throw new RangeError("Too few vertices, that's no polygon!");
				return;
			}
			
			this.polygonVertices 			= constructHull ? PolyUtils.convexHull(vertices) : vertices;
			triangleMeshHasCentralVertex 	= addCentralVertexToTriangleMesh;
			init(useBoundsForCentroid);	
		}
		
		private function init(useBoundsForCentroid:Boolean):void {
			
			var t:Vector.<Vertex> = polygonVertices.concat();
			
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
			const cnt:Vector3D = useBoundsForCentroid ? new Vector3D(bounds.x + (bounds.width / 2), bounds.y + (bounds.height / 2)) : PolyUtils.getCentroid(polygonVertices);
			polygonVertices.map(function(item:Vertex, index:int, vector:Vector.<Vertex>):void {
				item.x -= cnt.x;
				item.y -= cnt.y;
			});
			
			t = polygonVertices.concat();
			
			if (triangleMeshHasCentralVertex) { // ? add central vetex
				t.unshift(new Vertex(0,0,0)); // we're already aligned with centroid at 0,0 - so add the central vertex at 0,0 too
			}
			
			t.fixed = true;
			// triangulate
			triangleVertices = PolyUtils.triangulateConvexPolygon(t);
		}
		
		static public function fromNapeBodyShapes(body:Body, width:int, height:int):PolygonData {
			
			var shapeIndex		:int;
			var numShapes		:int;
			var shapes			:ShapeList;
			
			var verts			:Vector.<Vertex>	= new Vector.<Vertex>();
			var triangles		:Vector.<Vertex>	= new Vector.<Vertex>();
			
			var polyWorldVerts	:Vec2List;
			var pCount			:int;
			var pIndex			:int;
			
			var polygonData:PolygonData 				= new PolygonData(null);
			polygonData.bounds 							= new Rectangle(0,0, width, height);
			polygonData.alignedAboutCentroid 			= true;
			polygonData.triangleMeshHasCentralVertex 	= false;
			polygonData.polygonVertices 				= null;
			
			shapes 			= body.shapes;
			numShapes 		= shapes.length;
			shapeIndex 		= -1;
			while (++shapeIndex < numShapes) {
				polyWorldVerts	= shapes.at(shapeIndex).castPolygon.worldVerts;
				pCount			= polyWorldVerts.length;
				pIndex			= -1;
				
				while (++pIndex < pCount) {
					verts.push(new Vertex(polyWorldVerts.at(pIndex).x, polyWorldVerts.at(pIndex).y));
				}
				
				if (verts.length > 2) {
					triangles 		= triangles.concat(PolyUtils.triangulateConvexPolygon(verts));
					verts.fixed 	= false;
					verts.length 	= 0;
				}
			}
			
			triangles.fixed 				= true;
			polygonData.triangleVertices 	= triangles;
			
			return polygonData;
		}
	}
}