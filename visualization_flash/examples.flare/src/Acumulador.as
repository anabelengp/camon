package 
{
	import flare.animate.TransitionEvent;
	import flare.animate.Transitioner;
	import flare.data.DataSet;
	import flare.display.TextSprite;
	import flare.util.Colors;
	import flare.util.Shapes;
	import flare.util.Strings;
	import flare.vis.Visualization;
	import flare.vis.controls.HoverControl;
	import flare.vis.controls.TooltipControl;
	import flare.vis.data.Data;
	import flare.vis.data.DataSprite;
	import flare.vis.data.NodeSprite;
	import flare.vis.events.SelectionEvent;
	import flare.vis.events.TooltipEvent;
	import flare.vis.operator.layout.StackedAreaLayout;
	
	import flash.display.Shape;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import mx.collections.ArrayCollection;
	
	import org.axiis.data.DataSet;
	
	[SWF(backgroundColor="#ffffff", frameRate="30")]
	public class Acumulador extends App
	{
		private var vis:Visualization;
		private var labelMask:Shape = new Shape();
		
		private var ds:org.axiis.data.DataSet = new org.axiis.data.DataSet();
		
		private var file_name:String = "data/turkey2010_day_count.csv";
		
		protected override function init():void {
			var loader:URLLoader = new URLLoader(new URLRequest(file_name));
			loader.addEventListener(Event.COMPLETE, start_rendering);
		}
		
		private function start_rendering(e:Event):void {
			ds.processCsvAsTable(e.target.data, false);
			
			visualize(build_data());
		}
		
		private function get_header() : Array {
			var original_header:Array = ds.data.table.header;
			var header:Array = new Array();
			
			for (var i:uint = 1; i<original_header.length; i++) {
				header.push(original_header[i]);
			}
			
			return header;
		}
		
		private function visualize(data:Data):void {
			// create the visualization
			vis = new Visualization(data);
			
			var header:Array = get_header();
			
			vis.bounds.x = 20;
			vis.bounds.y = 20;
			vis.bounds.width = 1400;
			vis.bounds.height = 650;
			
			vis.operators.add(new StackedAreaLayout(header));
			
			vis.data.nodes.visit(function(d:DataSprite):void {
				d.fillColor = Colors.rgba(0xAA,0xAA,100 + uint(155*Math.random()));
				d.fillAlpha = 1;
				d.lineAlpha = 0;
				d.shape = Shapes.POLYGON;
			});
			
			// provide tooltip on mouse hover
			vis.controls.add(new TooltipControl(NodeSprite, null,
				function(evt:TooltipEvent):void {
					var text:String = evt.node.name + " MÁXIMO VALOR: ";
					
					var valores:Object = evt.node.data;
					var max:int = 0, max_date:String = "12";
					
					for (var name in valores) {
						if (max < valores[name]) {
							max_date = name;
							max = valores[name];
						}
					}
					
					text += max;
					
					text += " EL DÍA: ";
					text += max_date;
					
					TextSprite(evt.tooltip).htmlText = Strings.format(text);
				}
			));
			
			// highlight nodes on mouse over
			vis.controls.add(new HoverControl(NodeSprite,
				// don't change drawing order of nodes
				HoverControl.MOVE_AND_RETURN,
				// highlight
				function(evt:SelectionEvent):void {
					evt.node.lineColor = 0xffFF0000;
				},
				// unhighlight
				function(evt:SelectionEvent):void {
					var n:NodeSprite = evt.node;
					n.lineColor = 0xffcccccc;
				}
			));
			
			vis.update();
			addChild(vis);
			
			// add mask to hide animating labels
			vis.xyAxes.addChild(labelMask);
			vis.xyAxes.yAxis.labels.mask = labelMask;
			
			// perform layout
			//resize(_appBounds);
		}
		
		public override function resize(b:Rectangle):void {
			if (vis) {
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
		
		public function build_data() : Data {
			var cols:Array = ds.data.table.header;
			var col:String;
			
			var result:Data = new Data();
			var data:DataSprite = null;
			var value:int = 0, word:String = null, date:String = null;
			
			for each (var row:Object in ds.data.table.rows) {
				word = row.columns[0].value;
				data = result.addNode();
				
				data.name = word;
				
				for (var i:uint = 1; i<cols.length; i++) {
					date  = cols[i];
					value = parseInt(row.columns[i].value);
					
					data.data[date] = value; 
				}
			}
			
			return result;
		}
		
	} // end of class Stacks
}