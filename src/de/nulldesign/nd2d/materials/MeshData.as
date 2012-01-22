 package de.nulldesign.nd2d.materials {
	
	/**
	 * ...
	 * @author Mike Almond - https://github.com/mikedotalmond
	 */
	 
	
	import de.nulldesign.nd2d.geom.Face;
	
	public final class MeshData {
	
		public var faceList	:Vector.<Face>;
		public var width	:Number;
		public var height	:Number;
		
		public function MeshData(faceList:Vector.<Face>, width:Number, height:Number) {
			this.faceList 	= faceList;
			this.width 		= width;
			this.height 	= height;
		}
	}
}