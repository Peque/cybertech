package reset.bluetoothchat.tab;

import android.app.Activity;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.SeekBar;
import android.widget.SeekBar.OnSeekBarChangeListener;
import android.widget.TextView;
import android.widget.Toast;

public class PidFragment extends Fragment {
	
	private static final String TAG = "PidFragment";
	EditText pEditText;
	EditText iEditText;
	EditText dEditText;
	public static final String ARG_SECTION_NUMBER = "section_number";
	public static final String ARG_FRAGMENT_NAME = "fragment_name";
	public static float Kp, Ki, Kd; 
	
	public PidFragment() {
		// TODO Auto-generated constructor stub
	}
	
	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		
		// Get context
		View v;
		final BluetoothChat bActivity = ((BluetoothChat)getActivity());
    	v = inflater.inflate(R.layout.pid_conf, container, false);
    	
    	// Layout elements
    	
    	TextView pTextIncrement = (TextView) v.findViewById(R.id.TextView_P);
    	TextView iTextIncrement = (TextView) v.findViewById(R.id.TextView_I);
    	TextView dTextIncrement = (TextView) v.findViewById(R.id.TextView_D);
    	
    	pEditText = (EditText) v.findViewById(R.id.pEditText);
    	iEditText = (EditText) v.findViewById(R.id.iEditText);
    	dEditText = (EditText) v.findViewById(R.id.dEditText);
    	
    	Button button1 = (Button) v.findViewById(R.id.button1);
    	
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
    	
    	button1.setOnClickListener(new OnClickListener() {    
            @Override
            public void onClick(View v) {
                Activity activity = getActivity(); 
                if (activity != null) {
                	if (bActivity.isConnected()) {
	                	Toast.makeText(activity, "PID values sent", Toast.LENGTH_SHORT).show();
	                    updateKValues();
	                    bActivity.sendMessage(getString(R.string.set_P) + Kp + '\n' );
	                    bActivity.sendMessage(getString(R.string.set_I) + Ki  + '\n');
	                    bActivity.sendMessage(getString(R.string.set_D) + Kd  + '\n');     
                	}
                }
            }
        });
    	
    	final SeekBar p_SeekBar = (SeekBar) v.findViewById(R.id.SeekBar_P);
    	p_SeekBar.setOnSeekBarChangeListener(new SeekBarChangeListener(pTextIncrement, pEditText, seekValues));
    	
    	final SeekBar i_SeekBar = (SeekBar) v.findViewById(R.id.SeekBar_I);
    	i_SeekBar.setOnSeekBarChangeListener(new SeekBarChangeListener(iTextIncrement, iEditText, seekValues));
    	
    	final SeekBar d_SeekBar = (SeekBar) v.findViewById(R.id.SeekBar_D);
    	d_SeekBar.setOnSeekBarChangeListener(new SeekBarChangeListener(dTextIncrement, dEditText, seekValues));

    	return v;
	}
	
	private void updateKValues() {
		// TODO Auto-generated method stub
		Kp = Float.valueOf(pEditText.getText().toString());
		Ki = Float.valueOf(iEditText.getText().toString());;
		Kd = Float.valueOf(dEditText.getText().toString());
	}
	
	private class SeekBarChangeListener implements OnSeekBarChangeListener {
		TextView incrementText;
		EditText baseText;
		float seekValues [];
	
		public SeekBarChangeListener(TextView incrementText, EditText baseText, float[] seekValues) {
			// TODO Auto-generated constructor stub
			this.incrementText = incrementText;
			this .baseText = baseText;
			this.seekValues = seekValues;
		}
		
		@Override
		public void onProgressChanged(SeekBar seekBar, int progress,
				boolean fromUser) {
			// TODO Auto-generated method stub
			if (fromUser == true) {
				incrementText.setText(Float.toString(seekValues[progress]) + " %");
				}						
		}
		
		@Override
		public void onStartTrackingTouch(SeekBar seekBar) {
			// TODO Auto-generated method stub		
		}
		
		@Override
		public void onStopTrackingTouch(SeekBar seekBar) {
			// TODO Auto-generated method stub
			float base = Float.valueOf(baseText.getText().toString());
			int progress = seekBar.getProgress();
			float newValue =  (seekValues [progress] / 100 * base );
			baseText.setText(Float.toString(newValue));
			seekBar.setProgress(8);
			incrementText.setText("");
			
			final BluetoothChat bActivity = ((BluetoothChat)getActivity());
			updateKValues();
            bActivity.sendMessage(getString(R.string.set_PID) + Kp + ',' + Ki + ',' + Kd +  '\n' );
			             
		}
	}	
}
