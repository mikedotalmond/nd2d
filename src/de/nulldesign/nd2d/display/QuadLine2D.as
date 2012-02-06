package de.nulldesign.nd2d.display {
	
	/**
	 * ...
	 * @author Mike Almond - https://github.com/mikedotalmond
	 */
	
	import flash.geom.Vector3D;
	
	public class QuadLine2D extends QuadList2D {
		
		private const V0_temp		:Vector3D = new Vector3D();
		private const V1_temp		:Vector3D = new Vector3D();
		private const V2_temp		:Vector3D = new Vector3D();
		private const V3_temp		:Vector3D = new Vector3D();
		
		protected var lineX			:Number = 0;
		protected var lineY			:Number = 0;
		
		protected var thickness		:Number = 1;
		
		protected var lineAlpha		:Number = 1;
		protected var lineColor		:uint 	= 0x000000;
		
		public function QuadLine2D(maxQuads:uint=0, cyclic:Boolean=true) {
			super(maxQuads, cyclic);
			fillListWithQuads();
		}
		
		public function lineStyle(thickness:Number = 1, color:uint = 0, alpha:Number = 1):void {
			this.thickness 	= thickness;
			lineColor 		= color;
			lineAlpha 		= alpha;
		}
		
		public function moveTo(x:Number, y:Number):void {
			lineX = x;
			lineY = y;
			index++;
			if (index == quadList.length) index = 0;
		}
		
		public function lineTo(x:Number, y:Number):void {
			
			const dx			:Number = x - lineX;
			const dy			:Number = y - lineY;
			const theta			:Number = Math.atan2(y - lineY, x - lineX) + Math.PI / 2;
			const sinThetaThick	:Number = Math.sin(theta) * thickness;
			const cosThetaThick	:Number = Math.cos(theta) * thickness;
			
			V0_temp.x = -sinThetaThick;
			V0_temp.y = cosThetaThick;
			V1_temp.x = (cosThetaThick - sinThetaThick);
			V1_temp.y = (sinThetaThick + cosThetaThick);
			
			V2_temp.x = dx + (cosThetaThick - sinThetaThick);
			V2_temp.y = dy + (sinThetaThick + cosThetaThick);
			V3_temp.x = dx + (-sinThetaThick);
			V3_temp.y = dy + (cosThetaThick);
			
			quadList[index].x 		= lineX;
			quadList[index].y 		= lineY;
			quadList[index].color 	= lineColor;
			quadList[index].alpha 	= lineAlpha;
			quadList[index].setVertexPositions(V0_temp, V1_temp, V2_temp, V3_temp);
			quadList[index].visible = true;
		}
		
		public function cubicCurveTo(controlX1:Number, controlY1:Number, controlX2:Number, controlY2:Number, anchorX:Number, anchorY:Number):void {
			
		}
	}
}