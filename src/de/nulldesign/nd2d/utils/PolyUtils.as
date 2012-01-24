package de.nulldesign.nd2d.utils {
	
	import flash.geom.Vector3D;
	
	final public class PolyUtils {
		
		/**
		 *
		 * @param	pointCloud
		 * @return
		 */
		public static function convexHull(pointCloud:Vector.<Vector3D>):Vector.<Vector3D> {
			
			pointCloud.sort(sortVector3DByX); // minX -> maxX
			
			const n			:uint = pointCloud.length;
			const twoPi		:Number = Math.PI * 2;
			
			var point		:Vector3D = pointCloud[0];
			var hull		:Vector.<Vector3D> = new Vector.<Vector3D>();
			var angle		:Number = Math.PI / 2;
			var bestAngle	:Number;
			var bestIndex	:int;
			var i			:int = -1;
			var testAngle	:Number = 0;
			var testPoint	:Vector3D;
			
			var firstPass	:Boolean = true;
			
			while (firstPass || !point.equals(hull[0])) {
				
				firstPass = false;
				hull.push(point);
				
				bestAngle = Number.MAX_VALUE;
				
				i = -1;
				while(++i < n) {
					testPoint = pointCloud[i];
					if (testPoint.equals(point)) {
						continue;
					} else {
						testAngle = Math.atan2(testPoint.y - point.y, testPoint.x - point.x) - angle;
						while (testAngle < 0) testAngle += twoPi;
						if (testAngle < bestAngle){
							bestAngle = testAngle;
							bestIndex = i;
						}
					}
				}
				
				point = pointCloud[bestIndex];
				angle += bestAngle;
			}
			
			return hull;
		}
		
		
		public static function reposition(poly:Vector.<Vector3D>, offset:Vector3D):void {
			poly.forEach(
				function(item:Vector3D, index:int, vector:Vector.<Vector3D>):void {
					item.x += offset.x;
					item.y += offset.y;
				}
			);
		}
		
		public static function getArea(points:Vector.<Vector3D>):Number {
			
			var a	:Number = 0.0;
			var i	:int = -1;
			
			const n	:int = points.length;
			var j	:int = n - 1;
			
			while(++i < n)  {
				a += (points[j].x + points[i].x) * (points[j].y - points[i].y);
				j = i;
			}
			
			//trace("PolyArea = " + ((a < 0 ? -a : a) / 2));
			
			return (a < 0 ? -a : a) / 2;
		}
		
		/**
		 * http://en.wikipedia.org/wiki/Centroid#Centroid_of_polygon
		 * @param	points
		 * @return
		 */
		public static function getCentroid(poly:Vector.<Vector3D>):Vector3D {
			const A	:Number = 1.0 /  (6 * getArea(poly));
			
			var x	:Number = 0;
			var y	:Number = 0;
			
			const n	:int = poly.length - 1;
			var i	:int = -1;
			var b	:Number;
			
			while (++i < n) {
				b 	=	(poly[i].x * poly[uint(i + 1)].y - poly[uint(i + 1)].x * poly[i].y);
				x 	+= 	(poly[i].x + poly[i + 1].x) * b;
				y 	+= 	(poly[i].y + poly[i + 1].y) * b;
			}
			
			//trace("centroid: " + new Vector3D(A * x, A * y));
			
			return new Vector3D(A * x, A * y);
		}
		
		
		public static function sortVector3DByX(a:Vector3D, b:Vector3D):int {
			return (a.x == b.x) ? 0 : (a.x < b.x ? -1 : 1);
		}
		
		public static function sortVector3DByY(a:Vector3D, b:Vector3D):int {
			return (a.y == b.y) ? 0 : (a.y < b.y ? -1 : 1);
		}
	}
}