package es.camon {
	
	import com.shortybmc.data.parser.CSV;
	
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.net.URLRequest;
	
	public class CSVUtils {
		
		private var csv:CSV = null;
		private var loadGraphHandler:Function = null;
		
		public function CSVUtils(url:String, loadGraphHandler:Function) {
			this.loadGraphHandler = loadGraphHandler;
			
			csv = new CSV();
			
			csv.fieldSeperator = ','
			csv.fieldEnclosureToken= '"'
			csv.recordsetDelimiter= '\n'
			
			csv.load(new URLRequest(url));
			
			csv.addEventListener (Event.COMPLETE, this.completeHandler);
		}
		
		private function completeHandler (event : Event) : void {
			trace("Downloaded file!");
			
			this.loadGraphHandler();
		}
		
		public function getRecord(col_index:int) : Array {
			return csv.getRecordSet(col_index);
		}
		
		public function getColumnsData(col_names:Array) : Array {
			var col_name:String;
			var headers:Array = csv.header;
			var col_indexes:Array = new Array();
			
			for each (col_name in col_names) {
				col_indexes.push(headers.indexOf(col_name, 0));			
			}
			
			var data_list:Array = csv.data;
			var data_entry:Array = null;
			
			var filtered_data:Array = new Array();
			
			for each (data_entry in data_list) {
				var filtered_data_entry:Array = new Array();
				
				for (var i:int=0; i<col_names.length; i++) {
					filtered_data_entry[col_names[i]] = data_entry[col_indexes[i]];
				}
				
				filtered_data.push(filtered_data_entry);
			}
			
			return filtered_data;
		}
	}
}