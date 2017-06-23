package org.p2f1.models;

public class MainWindowModel {

	public boolean checkInputText(String sText){
		if(sText.length() > 0 && sText.length() < 300){
			//System.out.println(sText.length());
			return true;
		}	
		return false;
	}
	
}
