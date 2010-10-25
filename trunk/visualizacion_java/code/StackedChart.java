package prefuse.demos.curso;

import java.awt.BorderLayout;
import java.awt.event.MouseEvent;
import java.awt.geom.Rectangle2D;
import java.util.Iterator;

import javax.swing.JComponent;
import javax.swing.JFrame;
import javax.swing.JPanel;

import prefuse.Constants;
import prefuse.Display;
import prefuse.Visualization;
import prefuse.action.ActionList;
import prefuse.action.RepaintAction;
import prefuse.action.assignment.ColorAction;
import prefuse.action.layout.AxisLabelLayout;
import prefuse.action.layout.AxisLayout;
import prefuse.action.layout.Layout;
import prefuse.action.layout.StackedAreaChart;
import prefuse.activity.Activity;
import prefuse.controls.ControlAdapter;
import prefuse.controls.DragControl;
import prefuse.controls.HoverActionControl;
import prefuse.controls.PanControl;
import prefuse.controls.ZoomControl;
import prefuse.data.Table;
import prefuse.data.io.CSVTableReader;
import prefuse.data.query.ObjectRangeModel;
import prefuse.demos.curso.TreeMap.FillColorAction;
import prefuse.render.AxisRenderer;
import prefuse.render.DefaultRendererFactory;
import prefuse.render.LabelRenderer;
import prefuse.render.PolygonRenderer;
import prefuse.render.Renderer;
import prefuse.render.RendererFactory;
import prefuse.util.ColorLib;
import prefuse.util.ColorMap;
import prefuse.visual.DecoratorItem;
import prefuse.visual.NodeItem;
import prefuse.visual.VisualItem;
import prefuse.visual.VisualTable;
import prefuse.visual.expression.InGroupPredicate;

public class  StackedChart extends Display {
	
	public static final String FILE = "G:\\Documents and Settings\\Juanjo\\Escritorio\\Curso prefuse\\workspace\\prefuse\\data\\turkey2010_day_count.csv";
	final String group = "keywords";
	
	public StackedChart(Table t, String[] colnames) {
		super(new Visualization());
		
		//Se añade la tabla a la visualización
		VisualTable vt = m_vis.addTable(group, t);
		vt.addColumn(VisualItem.POLYGON, float[].class);
		vt.addColumn(VisualItem.POLYGON + ":start", float[].class);
		vt.addColumn(VisualItem.POLYGON + ":end", float[].class);
		
		//Establecer los renderers (poligono y axis)		
		RendererFactory drf = new CustomRendererFactory(); 
		m_vis.setRendererFactory(drf); 		
	
		//Establecer acciones
		//Acciones para el color
		ActionList colors = new ActionList();
		final ColorAction fillColor = new FillColorAction(group);
		final ColorAction strokeColor = new StrokeColorAction(group);
		colors.add(strokeColor);
		colors.add(fillColor);
		
		//Axis layout
		ObjectRangeModel orm = new ObjectRangeModel(colnames); 
		AxisLabelLayout xlabels = new AxisLabelLayout("xlab",Constants.X_AXIS,orm);
	
		//Acciones para el layout
		ActionList layout = new ActionList();
		layout.add(colors);
		layout.add(new RepaintAction());
		//Cargamos el layout StackedAreaChart indicando las columnas a tratar
		layout.add(new StackedAreaChart(group, VisualItem.POLYGON, colnames));
		//Cargamos el layout para los ejes
		layout.add(xlabels);
		
		//Añadimos los controladores
		addControlListener(new ZoomControl());
        addControlListener(new PanControl());
        
        addControlListener(new ControlAdapter() {
            public void itemEntered(VisualItem item, MouseEvent e) {
            	Display d = (Display)e.getSource();
            	if (item.isInGroup(group)){
            		d.setToolTipText(item.getString("keyword"));
            	}
            }
            public void itemExited(VisualItem item, MouseEvent e) {
            	Display d = (Display)e.getSource();
                d.setToolTipText(null);
            }
        });        
		setSize(900, 650);
		
		m_vis.putAction("layout", layout);
		m_vis.run("layout");
	}
	
	public static void main(String argv[]) {
		try{
			//Procesar los datos
			Table t = new CSVTableReader().readTable(FILE);
			
			//Get all the columns but te keyword
			String[] colnames = new String[t.getColumnCount()-1];
			for ( int i=0; i<colnames.length; ++i )
			{
				colnames[i] = t.getColumnName(i+1);
			}
			
			//Crear la visualización
			StackedChart stackedChart = new StackedChart(t, colnames); 
			
			//Renderizar la visualización
			JPanel panel = new JPanel(new BorderLayout());
	        panel.add(stackedChart, BorderLayout.CENTER);
	        
	        JFrame frame = new JFrame("StackedChart");
	        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
	        frame.setContentPane(stackedChart);
	        frame.pack();
	        frame.setVisible(true);
		}catch(Exception e){
			e.printStackTrace();
            System.exit(1);
		}
	}
	
	public static class FillColorAction extends ColorAction {
        private int[] palette = ColorLib.getHotPalette(35);

        public FillColorAction(String group) {
            super(group, VisualItem.FILLCOLOR);
        }
        
        public int getColor(VisualItem item) {
            return palette[item.getRow()];
        } 
    }
	
	public static class StrokeColorAction extends ColorAction {
        private int[] palette = ColorLib.getHotPalette(35);

        public StrokeColorAction(String group) {
            super(group, VisualItem.STROKECOLOR);
        }
        
        public int getColor(VisualItem item) {
            return palette[item.getRow()];
        } 
    }
	
	public static class CustomRendererFactory implements RendererFactory{ 
		Renderer polyR = new PolygonRenderer(Constants.POLY_TYPE_CURVE); 
		Renderer arX = new AxisRenderer(Constants.CENTER, Constants.TOP); 
		public CustomRendererFactory (){ 
			((PolygonRenderer) polyR).setCurveSlack(0.15f); 
		} 
		public Renderer getRenderer(VisualItem item) { 
			return item.isInGroup("xlab") ? arX : polyR; 
		} 
	};
}