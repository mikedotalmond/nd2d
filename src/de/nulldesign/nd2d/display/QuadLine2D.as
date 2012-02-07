package de.nulldesign.nd2d.display {
	
	/**
	 * ...
	 * @author Mike Almond - https://github.com/mikedotalmond
	 */
	
	import com.furusystems.logging.slf4as.ILogger;
	import com.furusystems.logging.slf4as.Logging;
	
	import flash.geom.Point;
	import flash.geom.Vector3D;
	
	public class QuadLine2D extends QuadList2D {
		
		static public const Logger	:ILogger 	= Logging.getLogger(QuadLine2D);		
		
		private const LastPosTemp	:Point 		= new Point();
		private const PosTemp		:Point 		= new Point();
		
		private const V0_temp		:Vector3D 	= new Vector3D();
		private const V1_temp		:Vector3D 	= new Vector3D();
		private const V2_temp		:Vector3D 	= new Vector3D();
		private const V3_temp		:Vector3D 	= new Vector3D();
		private const HalfPi		:Number 	= Math.PI / 2;
		
		
		protected var lineX			:Number 	= 0;
		protected var lineY			:Number 	= 0;
		protected var drawnSinceMove:Boolean 	= false;
		
		protected var thickness		:Number 	= 1;
		
		protected var lineAlpha		:Number 	= 1;
		protected var lineColor		:uint 		= 0x000000;
		protected var grow			:Boolean 	= false;
		
		public function QuadLine2D(maxQuads:uint=512, grow:Boolean=false) {
			super(maxQuads, false);
			fillListWithQuads();
			this.grow = grow;
			index = 0;
			Logger.info("Testing QuadLine2D methods");
		}
		
		public function clear():void {
			index = 0;
			var n:int = quadList.length;
			while (--n > -1) quadList[n].visible = false;
		}
		
		public function lineStyle(thickness:Number = 1, color:uint = 0x000000, alpha:Number = 1):void {
			this.thickness 	= thickness;
			lineColor 		= color;
			lineAlpha 		= alpha;
		}
		
		/**
		 * Position the 'pen' for drawing
		 * @param	x
		 * @param	y
		 */
		public function moveTo(x:Number, y:Number):void {
			drawnSinceMove = false;
			LastPosTemp.setTo(lineX = x, lineY = y);
		}
		
		/**
		 * 
		 * @param	px
		 * @param	py
		 */
		public function lineTo(px:Number, py:Number):void {
			
			const theta			:Number = Math.atan2(py - lineY, px - lineX) + Math.PI / 2;
			const sinThetaThick	:Number = Math.sin(theta) * thickness;
			const cosThetaThick	:Number = Math.cos(theta) * thickness;
			
			V2_temp.x = px + (cosThetaThick - sinThetaThick);
			V2_temp.y = py + (sinThetaThick + cosThetaThick);
			V3_temp.x = px + (-sinThetaThick);
			V3_temp.y = py + (cosThetaThick);
			
			if (drawnSinceMove) {
				const prevQuad:Quad2D = quadList[int(index == 0 ? quadList[quadList.length - 1] : index - 1)];
				quadList[index].setVertexPositions(prevQuad.getVertex(3), prevQuad.getVertex(2), V2_temp, V3_temp);
			} else {
				// start edge
				V0_temp.x = lineX + -sinThetaThick;
				V0_temp.y = lineY + cosThetaThick;
				V1_temp.x = lineX + (cosThetaThick - sinThetaThick);
				V1_temp.y = lineY + (sinThetaThick + cosThetaThick);
				quadList[index].setVertexPositions(V0_temp, V1_temp, V2_temp, V3_temp);
			}
			
			quadList[index].color 	= lineColor;
			quadList[index].alpha 	= lineAlpha;
			quadList[index].visible = true;
			drawnSinceMove 			= true;
			
			//
			if (++index == quadList.length) {
				if (grow) {
					quadList.fixed 	= false;
					quadList.push(quadList[quadList.length - 1].copy());
					quadList.fixed 	= true;
					Logger.warn("::lineTo - QuadList grown. New size = " + quadList.length.toString());
				} else {
					index --;
					Logger.warn("::lineTo - QuadList exhausted. Set growList=true, or the last quad will be recycled until clear()ed");
				}
			}
			
			lineX = px;
			lineY = py;
		}
		
		/**
		 * funciton signature based on the Graphics::cubicCurveTo API
		 * (but I don't expect it to draw like-for-like curves when compared to Graphics::cubicCurveTo)
		 * @param	controlX1
		 * @param	controlY1
		 * @param	controlX2
		 * @param	controlY2
		 * @param	anchorX
		 * @param	anchorY
		 * @param	segments	- number of segments to split the curve into for drawing... adjust depending on the length/scale of your curve.
		 */
		public function cubicCurveTo(controlX1:Number, controlY1:Number, controlX2:Number, controlY2:Number, anchorX:Number, anchorY:Number, segments:uint = 64):void {
			
			const bez			:BezierSegment 	= new BezierSegment(lineX, lineY, controlX1, controlY1, controlX2, controlY2, anchorX, anchorY);
			const inc			:Number 		= 1.0 / segments;
			const lastPos		:Point 			= LastPosTemp;
			const pos			:Point 			= PosTemp;
			
			var theta			:Number;
			var sinThetaThick	:Number;
			var cosThetaThick	:Number;
			var prevQuad		:Quad2D;
			var quad			:Quad2D  = quadList[index];
			var firstPass		:Boolean = !drawnSinceMove;
			var i				:int 	 = 0;
			
			while (++i < segments + 1) {
				bez.interpolateTo(i * inc, pos);
				theta 			= Math.atan2(pos.y - lastPos.y, pos.x - lastPos.x) + HalfPi;
				sinThetaThick 	= Math.sin(theta) * thickness;
				cosThetaThick 	= Math.cos(theta) * thickness;
				lastPos.setTo(pos.x, pos.y);
				
				// end
				V2_temp.x = pos.x + cosThetaThick - sinThetaThick;
				V2_temp.y = pos.y + sinThetaThick + cosThetaThick;
				V3_temp.x = pos.x - sinThetaThick;
				V3_temp.y = pos.y + cosThetaThick;
				
				quad = quadList[index];
				if (firstPass) { // start
					firstPass = false;
					quad.setVertexPositions(V3_temp, V2_temp, V2_temp, V3_temp);
				} else {	
					prevQuad = quadList[int(index == 0 ? quadList[quadList.length - 1] : index - 1)];
					quad.setVertexPositions(prevQuad.getVertex(3), prevQuad.getVertex(2), V2_temp, V3_temp);
					quad.color 		= lineColor;
					quad.alpha 		= lineAlpha;
					quad.visible 	= true;
				}
				
				if (++index == quadList.length) {
					if (grow) {
						quadList.fixed 	= false;
						quadList.push(quadList[quadList.length - 1].copy());
						quadList.fixed 	= true;
						Logger.warn("::cubicCurveTo - QuadList grown. New size = " + quadList.length.toString());
					} else {
						index --;
						Logger.warn("::cubicCurveTo - QuadList exhausted. Last quad will be recycled until clear()ed");
					}
				}
			}
			
			lineX = anchorX;
			lineY = anchorY;
			LastPosTemp.setTo(anchorX, anchorY);
			drawnSinceMove = true;
		}
	}
}


import flash.geom.Point;

internal class BezierSegment {
	
	public var startX	:Number;
	public var startY	:Number;
	public var controlX1:Number;
	public var controlY1:Number;
	public var controlX2:Number;
	public var controlY2:Number;
	public var anchorX	:Number;
	public var anchorY	:Number;
	
	/**
	 * Helper for getting values at positions along the defined bezier curve segment
	 * @param	startX
	 * @param	startY
	 * @param	controlX1
	 * @param	controlY1
	 * @param	controlX2
	 * @param	controlY2
	 * @param	anchorX
	 * @param	anchorY
	 */
	public function BezierSegment(startX:Number, startY:Number, controlX1:Number, controlY1:Number, controlX2:Number, controlY2:Number, anchorX:Number, anchorY:Number){
		this.startX 	= startX; //a
		this.startY		= startY;
		this.controlX1	= controlX1; //b
		this.controlY1	= controlY1;
		this.controlX2	= controlX2; //c
		this.controlY2	= controlY2;
		this.anchorX	= anchorX; //d
		this.anchorY	= anchorY;
	}
	
	/**
	 * 
	 * @param	percent
	 * @param	dest
	 */
	public function interpolateTo(percent:Number, dest:Point):void {
		const oneMinusPercent	:Number = 1.0 - percent;
		const aX				:Number = startX;
		const aY				:Number = startY;
		dest.x = ((((percent * percent) * (anchorX - aX)) + ((3 * oneMinusPercent) * ((percent * (controlX2 - aX)) + (oneMinusPercent * (controlX1 - aX))))) * percent) + aX;
		dest.y = ((((percent * percent) * (anchorY - aY)) + ((3 * oneMinusPercent) * ((percent * (controlY2 - aY)) + (oneMinusPercent * (controlY1 - aY))))) * percent) + aY;
	}
}