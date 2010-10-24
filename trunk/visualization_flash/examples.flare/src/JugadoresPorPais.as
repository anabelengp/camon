package
{
	import com.adobe.serialization.json.JSON;
	
	import flare.display.TextSprite;
	import flare.query.methods.eq;
	import flare.query.methods.fn;
	import flare.util.Shapes;
	import flare.util.Strings;
	import flare.vis.Visualization;
	import flare.vis.controls.ClickControl;
	import flare.vis.controls.HoverControl;
	import flare.vis.controls.TooltipControl;
	import flare.vis.data.Data;
	import flare.vis.data.NodeSprite;
	import flare.vis.data.Tree;
	import flare.vis.events.SelectionEvent;
	import flare.vis.events.TooltipEvent;
	import flare.vis.operator.encoder.PropertyEncoder;
	import flare.vis.operator.label.Labeler;
	import flare.vis.operator.layout.TreeMapLayout;
	
	import flash.display.StageQuality;
	import flash.filters.DropShadowFilter;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextFormat;
	
	import widgets.ProgressBar;
	
	[SWF(backgroundColor="#ffffff", frameRate="30")]
	public class JugadoresPorPais extends App
	{
		private static var _tipText:String = "<b>{0}</b><br/>{1:,0} bytes";
		
		private var _src:String =
			"http://svn.prefuse.org/flare/trunk/flare/flare/src/";
		private var _url:String = 
			"http://localhost:8080/turkey2010_players.csv";
			
		private var _vis:Visualization;
		
		protected override function init():void
		{
			import es.camon.CSVUtils;
			
			// download and parse CSV file
			var csvUtils:CSVUtils = new CSVUtils(_url, function():void {
				
				var data:Data = buildData(csvUtils.getColumnsData(new Array("JUGADOR", "REPETICIONES", "PAIS")));
				visualize(data);
			});
		}
		
		private function visualize(data:Data):void
		{
			// we're only drawing rectangles, so no one should notice...
			stage.quality = StageQuality.LOW;
			
			// create and add visualization
			addChild(_vis = new Visualization(data));
			
			// -- initialize visual items ----------------------
			
			// nodes are blocks, lower depths have thicker edges
			_vis.data.nodes.visit(function(n:NodeSprite):void {
				n.buttonMode = true;
				n.shape = Shapes.BLOCK;
				n.fillColor = 0xff4444ff;
				n.lineColor = 0xffcccccc;
				n.lineWidth = n.depth==1 ? 2 : n.childDegree ? 1 : 0;
				n.fillAlpha = n.depth / 25;
			});
			// no fill or mouse interaction for nodes with children
			_vis.data.nodes.setProperties({
				fillColor: 0,
				mouseEnabled: false
			}, null, "childDegree");
			
			// don't show any edges
			_vis.data.edges["visible"] = false;
			
			
			// -- define operators -----------------------------
			
			// perform a tree map layout
			_vis.operators.add(new TreeMapLayout("data.size"));

			// label top-level packages in new layer
			_vis.operators.add(new Labeler(
				"data.name",
				Data.NODES, new TextFormat("Arial", 14, 0, true),
				eq("depth",1), Labeler.LAYER));

			// add drop shadow to generated labels
			_vis.operators.add(new PropertyEncoder({
				"props.label.filters": [new DropShadowFilter(3,45,0x888888)]
			}, Data.NODES, eq("depth",1)));

			// run the operators
			_vis.update();
			
			
             // -- define interactive controls -----------------
			
			// highlight nodes on mouse over
			_vis.controls.add(new HoverControl(NodeSprite,
				// don't change drawing order of nodes
				HoverControl.MOVE_AND_RETURN,
				// highlight
				function(evt:SelectionEvent):void {
					evt.node.lineColor = 0xffFF0000;
					evt.node.fillColor = 0xffFFAAAA;
				},
				// unhighlight
				function(evt:SelectionEvent):void {
					var n:NodeSprite = evt.node;
					n.lineColor = 0xffcccccc;
					n.fillColor = 0xff4444FF;
					n.fillAlpha = n.depth / 25;
				}
			));
			
			// provide tooltip on mouse hover
			_vis.controls.add(new TooltipControl(NodeSprite, null,
				function(evt:TooltipEvent):void {
					TextSprite(evt.tooltip).htmlText = Strings.format(_tipText,
						evt.node.data.name, evt.node.data.size);
				}
			));
			
			// click to hyperlink to source code
			_vis.controls.add(new ClickControl(NodeSprite, 1,
				function(evt:SelectionEvent):void {
					var cls:String = evt.node.data.name;
					var url:String = _src + cls.split(".").join("/") + ".as";
					navigateToURL(new URLRequest(url), "_code");
				}
			));
			
			// perform layout
			resize(_appBounds);
		}
		
		public override function resize(b:Rectangle):void
		{
			if (_vis) {
				// make some extra room for the treemap border
				b.x += 1; b.y += 1; b.width -= 1; b.height -= 1;
				_vis.bounds = b;
				_vis.update();
			}
		}
		
		// --------------------------------------------------------------------
		
		/**
		 * Creates the visualized data.
		 */
		public static function buildData(jugadores:Array):Data
		{
			var arbol:Tree = new Tree();
			var paises:Object = {};
			
			var nodo_raiz:NodeSprite = arbol.addRoot();
			arbol.root.data = {name:"jugadores", size:0};
			
			var jugador:Object, nodo_hijo:NodeSprite;
			
			// build package tree
			for each (jugador in jugadores) {
				var pais:String = jugador["PAIS"];
				var nombre_jugador:String = jugador["JUGADOR"];
				var repeticiones:String = jugador["REPETICIONES"];
				
				if (! paises[pais]) {
					paises[pais] = arbol.addChild(nodo_raiz);
					paises[pais].data = {name: pais, size:0};
				}
				
				nodo_hijo = arbol.addChild(paises[pais]);
				nodo_hijo.data = {name: nombre_jugador, size:repeticiones}; 
			}
			
			return arbol;
		}
		
	} // end of class PackageMap
}