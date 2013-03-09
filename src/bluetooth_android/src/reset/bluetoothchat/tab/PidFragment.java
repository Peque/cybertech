package reset.bluetoothchat.tab;

import android.app.Activity;
import android.content.Context;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.View.OnClickListener;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.SeekBar;
import android.widget.SeekBar.OnSeekBarChangeListener;
import android.widget.TextView;
import android.widget.Toast;
import android.widget.ToggleButton;
import android.widget.CompoundButton;
import android.widget.CompoundButton.OnCheckedChangeListener;


public class PidFragment extends Fragment {
	
	private static final String TAG = "PidFragment";
	EditText pEditText;
	EditText iEditText;
	EditText dEditText;
	EditText sEditText;
	public final String ARG_SECTION_NUMBER = "section_number";
	public final String ARG_FRAGMENT_NAME = "fragment_name";
	public float Kp, Ki, Kd;
	public int speed;
	ToggleButton pidLockButton;
	
	public PidFragment() {
		// TODO Auto-generated constructor stub
	}
	
	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		// Get context
		View v;
		final BluetoothChat bActivity = ((BluetoothChat)getActivity());
    	v = inflater.inflate(R.layout.pid_conf, container, false);
    	
    	// Layout elements
    	
    	TextView pTextIncrement = (TextView) v.findViewById(R.id.TextView_P);
    	TextView iTextIncrement = (TextView) v.findViewById(R.id.TextView_I);
    	TextView dTextIncrement = (TextView) v.findViewById(R.id.TextView_D);
    	TextView sTextIncrement = (TextView) v.findViewById(R.id.TextView_S);
    	
    	pEditText = (EditText) v.findViewById(R.id.pEditText);
    	iEditText = (EditText) v.findViewById(R.id.iEditText);
    	dEditText = (EditText) v.findViewById(R.id.dEditText);
    	sEditText = (EditText) v.findViewById(R.id.sEditText);
    	
    	Button applyButton = (Button) v.findViewById(R.id.applyButton);
    	Button stopButton = (Button) v.findViewById(R.id.stopButton);
    	pidLockButton = (ToggleButton) v.findViewById(R.id.pidLockButton);
    	
    	// SeekBar Pos Values   	
    	final float seekValues [] = new float [17];
			seekValues [0] = 1;
			seekValues [1] = 5;
			seekValues [2] = 10;
			seekValues [3] = 50;
			seekValues [4] = 75;
			seekValues [5] = 90;
			seekValues [6] = 95;
			seekValues [7] = 99;
			seekValues [8] = 100;
	    	seekValues [9] = 101;
	    	seekValues [10] = 105;
	    	seekValues [11] = 110;
	    	seekValues [12] = 125;
	    	seekValues [13] = 150;
	    	seekValues [14] = 200;
	    	seekValues [15] = 500;
	    	seekValues [16] = 1000;
    	
    	applyButton.setOnClickListener(new OnClickListener() {    
            @Override
            public void onClick(View v) {
                Activity activity = getActivity(); 
                if (null != activity) {
                	if (bActivity.isConnected()) {
	                	Toast.makeText(activity, "PID values sent", Toast.LENGTH_SHORT).show();
	                    updateKValues();
	                    bActivity.sendMessage(getString(R.string.set_PID) + Kp + ',' + Ki + ',' + Kd +  '\n' );
	                    bActivity.sendMessage(getString(R.string.set_Max_Speed) + speed  + '\n' );
                	}
                }
            }
        });
    	
    	stopButton.setOnClickListener(new OnClickListener() {    
          @Override
          public void onClick(View v) {
          	if (bActivity.isConnected()) {
                    bActivity.sendMessage(getString(R.string.stop) + '\n');    
          	}
          }
    	});
  	
    	pidLockButton.setOnCheckedChangeListener(new OnCheckedChangeListener() {

			@Override
			public void onCheckedChanged(CompoundButton arg0, boolean arg1) {
	            if (null != bActivity) {
	            	bActivity.mViewPager.setSwipingEnabled(!arg1);
	            	bActivity.sendMessage(getString(R.string.get_PID) + '\n');
	            	bActivity.sendMessage(getString(R.string.get_Max_Speed) + '\n');
		        }
			}
		});
    	
    	final SeekBar p_SeekBar = (SeekBar) v.findViewById(R.id.SeekBar_P);
    	p_SeekBar.setOnSeekBarChangeListener(new SeekBarChangeListener(pTextIncrement, pEditText, seekValues));
    	
    	final SeekBar i_SeekBar = (SeekBar) v.findViewById(R.id.SeekBar_I);
    	i_SeekBar.setOnSeekBarChangeListener(new SeekBarChangeListener(iTextIncrement, iEditText, seekValues));
    	
    	final SeekBar d_SeekBar = (SeekBar) v.findViewById(R.id.SeekBar_D);
    	d_SeekBar.setOnSeekBarChangeListener(new SeekBarChangeListener(dTextIncrement, dEditText, seekValues));

    	final SeekBar s_SeekBar = (SeekBar) v.findViewById(R.id.SeekBar_S);
    	s_SeekBar.setOnSeekBarChangeListener(new SeekBarChangeListener(sTextIncrement, sEditText, seekValues) {
    		@Override
    		public void onStopTrackingTouch(SeekBar seekBar) {
//    			float base = Float.valueOf(baseText.getText().toString());
    			speed = s_SeekBar.getProgress();
//    			float newValue =  (seekValues [progress] / 100 * base );
    			sEditText.setText(Integer.toString(speed));
//    			seekBar.setProgress(8);
    			incrementText.setText("");
    			updateKValues();
                bActivity.sendMessage(getString(R.string.set_Max_Speed) + speed +  '\n' );    			
    		}
    		
    		@Override
    		public void onProgressChanged(SeekBar seekBar, int progress,
    				boolean fromUser) {
    			if (fromUser == true) {
    				incrementText.setText(Integer.toString(progress));
    				}						
    		}
    	});
    	return v;
	}
	
	private void updateKValues() {
		Kp = Float.valueOf(pEditText.getText().toString());
		Ki = Float.valueOf(iEditText.getText().toString());
		Kd = Float.valueOf(dEditText.getText().toString());
		speed = Integer.valueOf(sEditText.getText().toString());
	}
	
	public void setKd(float kd) {
		Kd = kd;
		dEditText.setText(Float.toString(kd));
	}
	
	public void setKi(float ki) {
		Ki = ki;
		iEditText.setText(Float.toString(ki));
	}
	
	public void setKp(float kp) {
		Kp = kp;
		pEditText.setText(Float.toString(kp));
	}
	
	public void setSpeed(int s) {
		speed = s;
		sEditText.setText(Integer.toString(s));
	}
	
	private class SeekBarChangeListener implements OnSeekBarChangeListener {
		TextView incrementText;
		EditText baseText;
		float seekValues [];
	
		public SeekBarChangeListener(TextView incrementText, EditText baseText, float[] seekValues) {
			this.incrementText = incrementText;
			this .baseText = baseText;
			this.seekValues = seekValues;
		}
		
		@Override
		public void onProgressChanged(SeekBar seekBar, int progress,
				boolean fromUser) {
			if (fromUser == true) {
				float base = Float.valueOf(baseText.getText().toString());
				float newValue =  (seekValues [progress] / 100 * base );
				incrementText.setText(Float.toString(seekValues[progress]) + " % (" + newValue + ")" );
				}						
		}
		
		@Override
		public void onStartTrackingTouch(SeekBar seekBar) {
			// TODO Auto-generated method stub		
		}
		
		@Override
		public void onStopTrackingTouch(SeekBar seekBar) {
			float base = Float.valueOf(baseText.getText().toString());
			int progress = seekBar.getProgress();
			float newValue =  (seekValues [progress] / 100 * base );
			baseText.setText(Float.toString(newValue));
			seekBar.setProgress(8);
			incrementText.setText("");
			final BluetoothChat bActivity = ((BluetoothChat)getActivity());
			updateKValues();
			if (null != bActivity) {
	            bActivity.sendMessage(getString(R.string.set_PID) + Kp + ',' + Ki + ',' + Kd +  '\n' );
	            bActivity.sendMessage(getString(R.string.set_Max_Speed) + speed +  '\n' );
			}
		}
	}	
}
