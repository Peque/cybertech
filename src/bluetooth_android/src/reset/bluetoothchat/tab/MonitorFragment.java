package reset.bluetoothchat.tab;

import java.util.Timer;
import java.util.TimerTask;

import android.app.Activity;
import android.graphics.Color;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.CompoundButton;
import android.widget.SeekBar;
import android.widget.SeekBar.OnSeekBarChangeListener;
import android.widget.TextView;
import android.widget.Toast;
import android.widget.ToggleButton;
import android.widget.CompoundButton.OnCheckedChangeListener;

public class MonitorFragment extends Fragment {
	
	public static final String ARG_SECTION_NUMBER = "section_number";
	public static final String ARG_FRAGMENT_NAME = "fragment_name";
	BluetoothChat bActivity;
	
	Timer timer;
	
	SeekBar lineSeekBar;
	ToggleButton toggleUpdate;
	TextView textDigitalBat; 
	TextView textPowerBat;
	
	int linePos = 80;
	
	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		View v;
    	v = inflater.inflate(R.layout.monitor, container, false);
    	bActivity = ((BluetoothChat)getActivity());
    	
    	lineSeekBar = (SeekBar) v.findViewById(R.id.lineSeekBar);
    	toggleUpdate = (ToggleButton) v.findViewById(R.id.buttonUpdateMonitor);
    	
    	textDigitalBat = (TextView) v.findViewById(R.id.TextDigitalBat);
    	textPowerBat = (TextView) v.findViewById(R.id.TextPowerBat);
    	
    	lineSeekBar.setOnSeekBarChangeListener(new OnSeekBarChangeListener() {
			
			@Override
			public void onStopTrackingTouch(SeekBar seekBar) {				
			}
			
			@Override
			public void onStartTrackingTouch(SeekBar seekBar) {
			}
			
			@Override
			public void onProgressChanged(SeekBar seekBar, int progress,
					boolean fromUser) {
				// TODO Auto-generated method stub
				if (fromUser) {
					lineSeekBar.setProgress((int)linePos);		
				}
			}
		});
    	
    	 toggleUpdate.setOnCheckedChangeListener(new OnCheckedChangeListener() {

 			@Override
 			public void onCheckedChanged(CompoundButton arg0, boolean arg1) {
 				if (arg1) {
	            	timer = new Timer();
	            	
	            	// Line update task
	            	timer.schedule(new TimerTask() {
	            		public void run() {
	            			bActivity = ((BluetoothChat)getActivity());
	            			if (bActivity.isConnected()) 
	            				bActivity.sendMessage(getString(R.string.get_Line_Pos) + '\n');
	            		};
	            	}, 0, 200);
	            	
	//            	// Battery update task
	            	timer.schedule(new TimerTask() {
	            		public void run() {
	            			bActivity = ((BluetoothChat)getActivity());
	            			if (bActivity.isConnected())
	            				bActivity.sendMessage(getString(R.string.get_Battery_Charge) + '\n');
	            		};
	            	}, 0, 10000);
 				} 				
 				else {
 					timer.cancel();
 					timer.purge();
 				}
            }
        });
    	return v;
	}
	
	public MonitorFragment getMonitorFragment() {
		return this;
	}
	
	public void setPBat(Float f) {
		String s;
		s = String.valueOf(f * 2).substring(0, 4) + " V";
		if (f > 3.6)
			textPowerBat.setTextColor(Color.GREEN);
		else if (f > 3.2 && f < 3.6)
			textPowerBat.setTextColor(Color.YELLOW);
		else
			textPowerBat.setTextColor(Color.RED);
		textPowerBat.setText(s);
	}

	public void setDBat(Float f) {
		String s;
		s = String.valueOf(f * 2).substring(0, 4) + " V";
		if (f > 3.6)
			textDigitalBat.setTextColor(Color.GREEN);
		else if (f > 3.2 && f < 3.6)
			textDigitalBat.setTextColor(Color.YELLOW);
		else
			textDigitalBat.setTextColor(Color.RED);
		textDigitalBat.setText(s);
	}

	public void setLPos(float parseFloat) {
		linePos = (Math.round(parseFloat *10));
		lineSeekBar.setProgress(linePos);			
	}

}

