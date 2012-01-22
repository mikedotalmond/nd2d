package de.nulldesign.nd2d.materials {
	
	import flash.geom.Vector3D;
	
	/**
	 * ...
	 * @author Mike Almond - https://github.com/mikedotalmond
	 */
	 
	public class AMesh2DMaterial extends AMaterial {
		
		protected var halfWidth			:Number;
		protected var halfHeight		:Number;
		protected var meshWidth			:Number;
		protected var meshHeight		:Number;
		
		public var registrationOffset	:Vector3D;
		
        public function AMesh2DMaterial(meshWidth:Number, meshHeight:Number) {
			this.meshWidth  	= meshWidth;
			this.meshHeight 	= meshHeight;
			this.halfWidth 		= meshWidth / 2;
			this.halfHeight 	= meshHeight / 2;
			registrationOffset 	= new Vector3D(-halfWidth, -halfHeight);
            drawCalls 			= 1;
        }
    }
}