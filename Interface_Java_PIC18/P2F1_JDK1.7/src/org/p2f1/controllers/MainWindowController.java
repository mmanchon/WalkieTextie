package org.p2f1.controllers;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.JButton;
import javax.swing.JComboBox;
import javax.swing.JOptionPane;

import org.p2f1.models.MainWindowModel;
import org.p2f1.models.ThreadPorts;
import org.p2f1.views.MainWindowView;

import com.SerialPort.SerialPort;

public class MainWindowController implements ActionListener{

	private MainWindowView view = null;
	private MainWindowModel model = null;
	private SerialPort sp = null;
	private ThreadPorts tp = null;
	private boolean done=false;
	
	public MainWindowController(MainWindowView view, MainWindowModel model){
		try{
			this.sp = new SerialPort();	
			this.tp = new ThreadPorts(sp,this);
			this.view = view;
			this.model = model;
			this.view.associateController(this);
			this.view.setBaudRateList(sp.getAvailableBaudRates());
			this.view.setPortsList(sp.getPortList());
			
		}catch(Exception e){
			System.out.println(e.getMessage());
		}
	}

	@Override
	public void actionPerformed(ActionEvent e) {
		
		if(e.getSource() instanceof JButton){
			JButton btn = (JButton) e.getSource();
			switch(btn.getName()){
				case MainWindowView.BTN_RF:
					//TODO Afegir el codi per enviar per RF
					int enviarf = 2;
					try {
						sp.writeByte((byte)enviarf);
					} catch (Exception e2) {
						// TODO Auto-generated catch block
						e2.printStackTrace();
					}
					//JOptionPane.showMessageDialog(null, "M'has de programar!", "Missatge",JOptionPane.INFORMATION_MESSAGE);
					break;
				case MainWindowView.BTN_UART:
					//TODO Afegir el codi per enviar per UART
					if(model.checkInputText(view.getText())){
						
						
						try {
							tp.setStatus(false);
							enviarMensage();
							tp.setStatus(true);
							/*byteFinal = sp.readByte();
							ascii = byteFinal;
							
							while(ascii==0){
								byteFinal = sp.readByte();
								ascii = byteFinal;	
							}
							
							while(ascii!=3){
								byteFinal = sp.readByte();
								ascii = byteFinal;
								
								if(ascii!=0 && ascii!=3){
									System.out.println((char)ascii);
									sp.writeByte((byte) 1);
								}
								
							}*/
							
							/*read_byte = sp.readByte();
							ascii = read_byte;
							while(ascii == 0){
								read_byte = sp.readByte();
								ascii = read_byte;
							}
							System.out.println((char)ascii);*/
							//tp.setStatus(true);

						} catch (Exception e1) {
							// TODO Auto-generated catch block
							e1.printStackTrace();
						}
						//JOptionPane.showMessageDialog(null, "Mensaje enviado!", "Missatge",JOptionPane.INFORMATION_MESSAGE);
					}else{
						JOptionPane.showMessageDialog(null, "Has de inserir text!", "Missatge",JOptionPane.ERROR_MESSAGE);
					}
					break;
				
			}
		}
		if(e.getSource() instanceof JComboBox<?>){
			JComboBox<?> jcb = (JComboBox<?>)e.getSource();
			if(jcb.getName().equals("BAUD")){
				if(done){
					tp.setStatus(false);
					tp.closePort();
					tp.setPortBaudrate();
					tp.abrirPuerto();
					tp.setStatus(true);
				}else{
					done = true;
				}
			}
		}
	}
	
	public void showView(){
		view.setVisible(true);
	}
	
	public void startListening(){
		tp.setPortBaudrate();
		tp.abrirPuerto();
		tp.run();
	}
	
	public int getBaudrateFromView(){
		return (int)view.getBaudRate();
	}
	
	public String getPortFromView(){
		return view.getSelectedPort().toString();
	}
	
	public void enviarMensage() throws Exception{
		String port,text;
		int baudrate,ascii;
		byte[] b;
		byte byteFinal= 0;
		byte botonrf = 1;
		byte fiString = '=';
		port = (String)this.view.getSelectedPort();
		text = view.getText();
		baudrate = (int)view.getBaudRate();
		b  = text.getBytes();
		
		//tp.setStatus(false);
		int length = b.length;
		System.out.println("ENVIO");
		sp.writeByte(botonrf);
		
		for(int i = 0; i < length; i++){
			sp.writeByte(b[i]);
		}
		sp.writeByte(fiString);
		sp.writeByte(byteFinal);
		
		/*byteFinal = sp.readByte();
		ascii = byteFinal;
		
		while(ascii==0){
			byteFinal = sp.readByte();
			ascii = byteFinal;	
		}
		
		while(ascii!=3){
			byteFinal = sp.readByte();
			ascii = byteFinal;
			
			if(ascii!=0 && ascii!=3){
				System.out.println((char)ascii);
				sp.writeByte((byte) 1);
			}
			
		}*/
		
	}
	
}
