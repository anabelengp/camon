package prefuse.demos.curso;

import java.io.FileInputStream;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import prefuse.data.Node;
import prefuse.data.Tree;
import prefuse.data.io.CSVTableReader;
import prefuse.data.io.TableReadListener;
import prefuse.data.parser.DataParseException;
import prefuse.util.ArrayLib;

public class TreeReader extends CSVTableReader implements TableReadListener{

	private Tree tree = new Tree();
	private int[] columns = {1, 3};
	private Node root = null;
	private Node parentNode = null;
	private int weightCol = 5;
	private int colorCol = 7;

	/* Row must be in order: Parent, son, ..., weight, color*/
	public TreeReader() {
		super();
		this.root = this.tree.addRoot();
		this.root.getTable().addColumn("name", String.class);
		this.root.getTable().addColumn("weight", int.class);
		this.root.getTable().addColumn("color", int.class);
		this.parentNode = this.root;
	}
	
	public Tree read(FileInputStream file){
		try{
			this.read(file, this);
		}catch(Exception e){
			e.printStackTrace();
            System.exit(1);
		}
		return this.tree;
	}

	public void readValue(int line, int col, String value)
			throws DataParseException {
		if (line>1){ //child nodes
			if (ArrayLib.find(this.columns, col) >= 0){//Useful column
				Iterator children = this.parentNode.children();
				while(children.hasNext()){
					Node child = (Node) children.next();
					String name = child.getString(0);
					if (name.compareToIgnoreCase(value) == 0){
						this.parentNode = child;
						return;
					}
				}
				//Node not found -> Add it to the Tree
				Node newNode = this.tree.addChild(this.parentNode);
				newNode.setString("name", value);
				this.parentNode = newNode;
			}
			else if (col == this.weightCol){
				this.parentNode.setInt("weight", Integer.valueOf(value).intValue());
			}else if (col == this.colorCol){
				this.parentNode.setInt("color", Integer.valueOf(value).intValue());
				this.parentNode = this.root;
			}
		}
	}

}
