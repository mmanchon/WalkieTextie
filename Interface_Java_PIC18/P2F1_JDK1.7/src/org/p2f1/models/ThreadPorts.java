package org.p2f1.models;

import org.p2f1.controllers.MainWindowController;
import org.p2f1.models.MainWindowModel;
import org.p2f1.views.MainWindowView;
import com.SerialPort.SerialPort;

public class ThreadPorts implements Runnable {
	private int ascii;
	private String caracter;
	private boolean running;
	private SerialPort sp = null;
	private MainWindowView view = null;
	private MainWindowController controller = null;
	private int baudrate;
	private String port;
	private boolean stop = true;

	public ThreadPorts(SerialPort sp,MainWindowController controller) {
			this.sp = sp;
			this.controller = controller;
	}

	public void run(){
		running = true;
		int ascii;
		byte readByte;
		
		try {
			while(stop){
				//System.out.println("is running");
				Thread.sleep(3);
				while(running){
					readByte=sp.readByte();
					ascii = readByte;
				
					while(ascii == 0 && running){
						readByte=sp.readByte();
						ascii = readByte;
						/*System.out.println("Puerto"+ port);
						System.out.println("Baud "+baudrate );*/
					}
					
					if(ascii!=0 && running){
						//running = true;
						//System.out.println("He recibido algo");
						controller.enviarMensage();
					}
					//running=false;

					
					//System.out.println("He surtit");
					//Thread.sleep(1000);
				}
				
			}
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	public boolean isRunning(){
		return this.running;
	}
	
	public void setStatus(boolean status){
		this.running = status;
		//System.out.println(running);
	}
	
	public void setView(MainWindowView view){
		this.view = view;
	}
	
	public void setPortBaudrate(){
		this.port = controller.getPortFromView();
		this.baudrate = controller.getBaudrateFromView();
	}
	
	public boolean abrirPuerto(){
		try {
			sp.openPort(this.port,this.baudrate);
			//System.out.println("Esta abierto");
			return true;
		} catch (Exception e) {
			// TODO Auto-generated catch block
			//e.printStackTrace();
			//System.out.println("Esta cerrado");
			return false;
		}
	}
	
	public void closePort(){
		sp.closePort();
	}
}
