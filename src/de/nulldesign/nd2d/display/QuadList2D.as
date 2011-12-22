package de.nulldesign.nd2d.display {
	import flash.geom.Vector3D;
	
	/**
	 * ...
	 * @author Mike Almond
	 */
	
	public final class QuadList2D extends Node2D {
		
		static public const EDGE_TOP	:String = "edgeTop";//1,2
		static public const EDGE_RIGHT	:String = "edgeRight";//2,3
		static public const EDGE_BOTTOM	:String = "edgeBottom";//3,4
		static public const EDGE_LEFT	:String = "edgeLeft";//4,1
		
		protected var quadList			:Vector.<Quad2D>;
		protected var index				:uint = 0;
		protected var maxQuads			:uint = 0;
		protected var cyclic			:Boolean;
		
		public function QuadList2D(maxQuads:uint=0, cyclic:Boolean=true) {
			super();
			this.maxQuads 	= maxQuads;
			this.cyclic 	= cyclic;
			quadList 		= new Vector.<Quad2D>();
		}
		
		/**
		 * Pre-populate the quad list with identical quads, optionally copied from an <code>origin</code> Quad2D 
		 * @param	startVisible	Make the created quad visible immediately?
		 * @param	origin			An optinal Quad2D object to make copies from 
		 */
		public function fillListWithQuads(startVisible:Boolean = false, origin:Quad2D=null):void {
			if (maxQuads == 0) {
				throw new RangeError("maxQuads is zero, set to a positive integer before filling the list.");
			} else {
				var n:int = maxQuads;
				quadList = new Vector.<Quad2D>(n, true);
				while (--n > -1) {
					quadList[n] = addChild(origin ? origin.copy() : new Quad2D(1, 1)) as Quad2D;
					quadList[n].visible = startVisible;
				}
			}
		}
		
		public function addQuad(quad:Quad2D):void {
			if (maxQuads == 0 || quadList.length < maxQuads) {
				index = quadList.length;
				quadList.fixed = false;
				quadList.push(addChild(quad) as Quad2D);
				quadList.fixed = true;
			} else if (cyclic) {
				index++;
				if(index == quadList.length) index = 0;
				quadList[index].setPropertiesFromQuad(quad);			
			} else {
				throw new RangeError("Quad list is full, and not cyclic");
			}
		}
		
		public function extrudeFromLastQuad(vOffsetA:Vector3D, vOffsetB:Vector3D, edge:String = QuadList2D.EDGE_TOP):void {
			extrudeFromQuadAt(index, vOffsetA, vOffsetB, edge);
		}
		
		public function extrudeFromQuadAt(idx:uint, vOffsetA:Vector3D, vOffsetB:Vector3D, edge:String = QuadList2D.EDGE_TOP):void {
			
			var sourceQuad:Quad2D = quadList[idx];
			
			if (index + 1 == maxQuads && cyclic) {
				index = 0;
			} else if(index < quadList.length-1){
				index++;
			} else {
				addQuad(sourceQuad.copy());
			}
			
			switch(edge) {
				
				case QuadList2D.EDGE_TOP:
					quadList[index].setVertexPositions( //v1=v1+, v2=v2+, v3=v2, v4=v1
						sourceQuad.faceList[0].v1.add(vOffsetA),
						sourceQuad.faceList[0].v2.add(vOffsetB), 
						sourceQuad.faceList[0].v2,
						sourceQuad.faceList[0].v1);
					break;
					
				case QuadList2D.EDGE_RIGHT:
					quadList[index].setVertexPositions( //v1=v2, v2=v2+, v3=v3+, v4=v3
						sourceQuad.faceList[0].v2,
						sourceQuad.faceList[0].v2.add(vOffsetA),
						sourceQuad.faceList[0].v3.add(vOffsetB), 
						sourceQuad.faceList[0].v3);
					break;
					
				case QuadList2D.EDGE_BOTTOM:
					quadList[index].setVertexPositions( //v1=v4, v2=v3, v3=v2+, v4=v1+
						sourceQuad.faceList[1].v3,
						sourceQuad.faceList[0].v3,
						sourceQuad.faceList[0].v3.add(vOffsetA), 
						sourceQuad.faceList[1].v3.add(vOffsetB));
					break;
					
				case QuadList2D.EDGE_LEFT:
					quadList[index].setVertexPositions( //v1=v1+, v2=v1, v3=v4, v4=v4+
						sourceQuad.faceList[0].v1.add(vOffsetB),
						sourceQuad.faceList[0].v1,
						sourceQuad.faceList[1].v3,
						sourceQuad.faceList[1].v3.add(vOffsetA))
					break;
					
				default:
					throw new ReferenceError("Unexpected edge type '" + edge + "'");
					return;
			}
			
			quadList[index].visible = true;
		}
	}
}