/*
 * ND2D - A Flash Molehill GPU accelerated 2D engine
 *
 * Author: Lars Gerckens
 * Copyright (c) nulldesign 2011
 * Repository URL: http://github.com/nulldesign/nd2d
 * Getting started: https://github.com/nulldesign/nd2d/wiki
 *
 *
 * Licence Agreement
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

package de.nulldesign.nd2d.display {

	import de.nulldesign.nd2d.geom.Face;
	import de.nulldesign.nd2d.geom.Vertex;
	import de.nulldesign.nd2d.materials.BlendModePresets;
	import de.nulldesign.nd2d.materials.Quad2DColorMaterial;
	import de.nulldesign.nd2d.utils.TextureHelper;
	import flash.geom.Vector3D;

	import flash.display3D.Context3D;

	public class Quad2D extends Node2D {

		public var faceList:Vector.<Face>;
		public var material:Quad2DColorMaterial;

		public function get topLeftColor():uint {
			return faceList[0].v1.color;
		}

		public function set topLeftColor(value:uint):void {
			var v:Vertex = faceList[0].v1;
			v.color = value;
			material.modifyColorInBuffer(0, v.r, v.g, v.b, v.a);
		}

		public function get topRightColor():uint {
			return faceList[0].v2.color;
		}

		public function set topRightColor(value:uint):void {
			var v:Vertex = faceList[0].v2;
			v.color = value;
			material.modifyColorInBuffer(1, v.r, v.g, v.b, v.a);
		}

		public function get bottomRightColor():uint {
			return faceList[0].v3.color;
		}

		public function set bottomRightColor(value:uint):void {
			var v:Vertex = faceList[0].v3;
			v.color = value;
			material.modifyColorInBuffer(2, v.r, v.g, v.b, v.a);
		}

		public function get bottomLeftColor():uint {
			return faceList[1].v3.color;
		}

		public function set bottomLeftColor(value:uint):void {
			var v:Vertex = faceList[1].v3;
			v.color = value;
			material.modifyColorInBuffer(3, v.r, v.g, v.b, v.a);
		}

		public function Quad2D(pWidth:Number, pHeight:Number) {

			_width = pWidth;
			_height = pHeight;

			faceList = TextureHelper.generateQuadFromDimensions(pWidth, pHeight);
			material = new Quad2DColorMaterial();
		
			topLeftColor = 0xFFFF0000;
			topRightColor = 0xFF00FF00;
			bottomRightColor = 0xFF0000FF;
			bottomLeftColor = 0xFFFFFF00;

			blendMode = BlendModePresets.NORMAL_NO_PREMULTIPLIED_ALPHA;
		}
		
		/**
		 * Set quad vertex positions (x,y)
		 * 
		 * Quad
		 * v1  v2
		 * v4  v3
		 * 
		 * Faces
		 * v1,v2,v3
		 * v1,v3,v4
		 * 
		 * @param	v1
		 * @param	v2
		 * @param	v3
		 * @param	v4
		 */
		public function setVertexPositions(v1:Vector3D = null, v2:Vector3D = null, v3:Vector3D = null, v4:Vector3D = null):void {
			// top left (face 1+2)
			if(v1){
				faceList[0].v1.x = faceList[1].v1.x = v1.x;
				faceList[0].v1.y = faceList[1].v1.y = v1.y;
			}
			// top right (face 1)
			if (v2) {
				faceList[0].v2.x = v2.x;
				faceList[0].v2.y = v2.y;
			}
			// bottom right (face 1+2)
			if (v3) {
				faceList[0].v3.x = faceList[1].v2.x = v3.x;
				faceList[0].v3.y = faceList[1].v2.y = v3.y;
			}
			// bottom left (face 2
			if (v4) {
				faceList[1].v3.x = v4.x;
				faceList[1].v3.y = v4.y;
			}
		}
		
		public function getVertex(index:uint):Vertex {
			switch(index) {
				case 0: return faceList[0].v1;
				case 1: return faceList[0].v2;
				case 2: return faceList[0].v3;
				case 3: return faceList[1].v3;
				default: throw new RangeError("I'm a quad! I only have 4 vertices.");
			}
		}
		
		public function copy():Quad2D {
			var q:Quad2D 		= new Quad2D(_width, _height);
			q.material			= new Quad2DColorMaterial();
			q.copyPropertiesOf(this);
			return q;		
		}
		
		public function copyPropertiesOf(source:Quad2D):void {
				
			var q2d:Quad2D 		= source as Quad2D;
			topLeftColor 		= q2d.topLeftColor;
			topRightColor 		= q2d.topRightColor;
			bottomRightColor 	= q2d.bottomRightColor;
			bottomLeftColor 	= q2d.bottomLeftColor;
			blendMode 			= q2d.blendMode;
			rotation 			= q2d.rotation;
			position 			= q2d.position;
			alpha 				= q2d.alpha;
			visible 			= q2d.visible;
			vx 					= q2d.vx;
			vy					= q2d.vy;
			
			setVertexPositions(q2d.getVertex(0),q2d.getVertex(1),q2d.getVertex(2),q2d.getVertex(3));
			
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
			material.render(context, faceList, 0, 2);
		}
		
		override public function set alpha(value:Number):void {
			var a:uint = uint(Math.round(value * 0xff)) << 24;
			topLeftColor 		= (topLeftColor & 0x00ffffff) | a;
			topRightColor 		= (topRightColor & 0x00ffffff) | a;
			bottomRightColor 	= (bottomRightColor & 0x00ffffff) | a;
			bottomLeftColor 	= (bottomLeftColor & 0x00ffffff) | a;
			
			super.alpha = value;
		}

		override public function dispose():void {
			if(material) {
				material.dispose();
				material = null;
			}
			super.dispose();
		}
	}
}
