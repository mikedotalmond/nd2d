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
		public function setVertexPositions(v1:Vector3D, v2:Vector3D, v3:Vector3D, v4:Vector3D):void {
			// top left (face 1+2)
			faceList[0].v1.x = faceList[1].v1.x = v1.x;
			faceList[0].v1.y = faceList[1].v1.y = v1.y;
			// top right (face 1)
			faceList[0].v2.x = v2.x;
			faceList[0].v2.y = v2.y;
			// bottom right (face 1+2)
			faceList[0].v3.x = faceList[1].v2.x = v3.x;
			faceList[0].v3.y = faceList[1].v2.y = v3.y;
			// bottom left (face 2)
			faceList[1].v3.x = v4.x;
			faceList[1].v3.y = v4.y;
		}
		
		public function copy():Quad2D {
			
			var q:Quad2D 		= new Quad2D(_width, _height);
			
			q.material			= new Quad2DColorMaterial();
			q.topLeftColor 		= topLeftColor;
			q.topRightColor 	= topRightColor;
			q.bottomRightColor 	= bottomRightColor;
			q.bottomLeftColor 	= bottomLeftColor;
			q.blendMode 		= blendMode;
			q.rotation 			= rotation;
			q.position 			= position;
			q.alpha 			= alpha;
			q.visible 			= visible;
			q.vx 				= vx;
			q.vy				= vy;
			
			q.setVertexPositions(faceList[0].v1, faceList[0].v2, faceList[0].v3, faceList[1].v3);
			
			return q;		
		}
		
		public function setPropertiesFromQuad(quad:Quad2D, updateVertices:Boolean=true):void {
			material			= new Quad2DColorMaterial();
			topLeftColor 		= quad.topLeftColor;
			topRightColor 		= quad.topRightColor;
			bottomRightColor 	= quad.bottomRightColor;
			bottomLeftColor 	= quad.bottomLeftColor;
			blendMode 			= quad.blendMode;
			rotation 			= quad.rotation;
			position 			= quad.position;
			alpha 				= quad.alpha;
			visible 				= quad.visible;
			vx 					= quad.vx;
			vy					= quad.vy;
			
			if(updateVertices) setVertexPositions(quad.faceList[0].v1, quad.faceList[0].v2, quad.faceList[0].v3, quad.faceList[1].v3);
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

		override public function dispose():void {
			if(material) {
				material.dispose();
				material = null;
			}
			super.dispose();
		}
	}
}
