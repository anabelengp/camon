package 
{
	
	import flare.animate.TransitionEvent;
	import flare.animate.Transitioner;
	import flare.data.DataSet;
	import flare.util.Colors;
	import flare.util.Shapes;
	import flare.vis.Visualization;
	import flare.vis.data.Data;
	import flare.vis.data.DataSprite;
	import flare.vis.operator.layout.StackedAreaLayout;
	
	import flash.display.Shape;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import mx.collections.ArrayCollection;
	
	import org.axiis.data.DataSet;
	
	[SWF(backgroundColor="#ffffff", frameRate="30")]
	public class Acumulador extends App
	{
		private var vis:Visualization;
		private var labelMask:Shape = new Shape();
		
		private var ds:org.axiis.data.DataSet = new org.axiis.data.DataSet();
		
		private var file_name:String = "data/kk.vsc";
		
		protected override function init():void {
			ds.processCsvAsTable(file_name, false);
			
		}
		
		/**
		 * Creates the visualized data.
		 */
		public static function buildData(jugadores:Array):Data
		{
			var jugador:Object;
			
			// build package tree
			for each (jugador in jugadores) {
				var pais:String = jugador["PAIS"];
				var nombre_jugador:String = jugador["JUGADOR"];
				var repeticiones:String = jugador["REPETICIONES"];
			}
			
			return new Data();
		}
		
		private function visualize(data:Data):void {
			// get data set with data values and column names
			var dataset:Object = getData(500);
			
			// create the visualization
			vis = new Visualization(dataset.data);
			vis.operators.add(new StackedAreaLayout(dataset.columns));
			vis.data.nodes.visit(function(d:DataSprite):void {
				d.fillColor = Colors.rgba(0xAA,0xAA,100 + uint(155*Math.random()));
				d.fillAlpha = 1;
				d.lineAlpha = 0;
				d.shape = Shapes.POLYGON;
			});
			
			vis.update();
			addChild(vis);
			
			// add mask to hide animating labels
			vis.xyAxes.addChild(labelMask);
			vis.xyAxes.yAxis.labels.mask = labelMask;
		}
		
		public override function resize(b:Rectangle):void {
			if (vis) {
				// make some extra room for the treemap border
				b.x += 1; b.y += 1; b.width -= 1; b.height -= 1;
				vis.bounds = b;
				vis.update();
			}
		}
		
		private function update(t:Transitioner):void
		{
			// toggle screen quality during animation to boost frame rate
			t.addEventListener(TransitionEvent.START,
				function(e:Event):void {stage.quality = StageQuality.LOW});
			t.addEventListener(TransitionEvent.END,
				function(e:Event):void {stage.quality = StageQuality.HIGH});	
			vis.update(t).play();
		}
		
		public static function getData(N:int):Object
		{
			var cols:Array = [-3,1,3,4,5,6,7,8,9,10];
			var i:uint, col:String;
			
			var data:Data = new Data();
			for (i=0; i<N; ++i) {
				var d:DataSprite = data.addNode();
				var j:uint = 0, s:Number;
				for each (col in cols) {
					s = 1 + int((j++)/2);
					d.data[col] = s*Math.random();
				}
			}
			
			return { data:data, columns:cols };
		}
		
	} // end of class Stacks
}