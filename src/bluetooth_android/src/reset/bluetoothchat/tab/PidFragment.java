package reset.bluetoothchat.tab;

import android.app.Activity;
import android.os.Bundle;
import android.support.v4.app.Fragment;
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
	
	public static final String ARG_SECTION_NUMBER = "section_number";
	public static final String ARG_FRAGMENT_NAME = "fragment_name";
	
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
    	TextView pTitle = (TextView) v.findViewById(R.id.textView_P_Title);
    	TextView iTitle = (TextView) v.findViewById(R.id.textView_I_Title);
    	TextView dTitle = (TextView) v.findViewById(R.id.textView_D_Title);
    	
    	final TextView pTextIncrement = (TextView) v.findViewById(R.id.TextView_P);
    	TextView iTextIncrement = (TextView) v.findViewById(R.id.TextView_I);
    	TextView dTextIncrement = (TextView) v.findViewById(R.id.TextView_D);
    	
    	final EditText pEditText = (EditText) v.findViewById(R.id.pEditText);
    	EditText iEditText = (EditText) v.findViewById(R.id.iEditText);
    	EditText dEditText = (EditText) v.findViewById(R.id.dEditText);
    	
    	// SeekBar Pos Values   	
    	final float seekValues [] = new float [17];
//    		seekValues [0] = -99;
//    		seekValues [1] = -95;
//    		seekValues [2] = -90;
//    		seekValues [3] = -50;
//    		seekValues [4] = -25;
//    		seekValues [5] = -10;
//    		seekValues [6] = -5;
//    		seekValues [7] = -1;
//    		seekValues [8] = 0;
//	    	seekValues [9] = 1;
//	    	seekValues [10] = 5;
//	    	seekValues [11] = 10;
//	    	seekValues [12] = 25;
//	    	seekValues [13] = 50;
//	    	seekValues [14] = 100;
//	    	seekValues [15] = 500;
//	    	seekValues [16] = 1000;
			seekValues [0] = 1;
			seekValues [1] = 5;
			seekValues [2] = 10;
			seekValues [3] = 50;
			seekValues [4] = 75;
			seekValues [5] = 90;
			seekValues [6] = 95;
			seekValues [7] = 99;
			seekValues [8] = 0;
	    	seekValues [9] = 101;
	    	seekValues [10] = 105;
	    	seekValues [11] = 110;
	    	seekValues [12] = 125;
	    	seekValues [13] = 150;
	    	seekValues [14] = 200;
	    	seekValues [15] = 500;
	    	seekValues [16] = 1000;

    	
    	Button button1 = (Button) v.findViewById(R.id.button1);
    	button1.setOnClickListener(new OnClickListener() {    
            @Override
            public void onClick(View v) {
                Activity activity = getActivity(); 
                if (activity != null) {
                    Toast.makeText(activity, "Botton Pushed", Toast.LENGTH_SHORT).show();
                    bActivity.sendMessage("testing");
                }
            }
        });
    	
    	final SeekBar p_SeekBar = (SeekBar) v.findViewById(R.id.SeekBar_P);
    	p_SeekBar.setOnSeekBarChangeListener(new OnSeekBarChangeListener()  {

			@Override
			public void onProgressChanged(SeekBar seekBar, int progress,
					boolean fromUser) {
				// TODO Auto-generated method stub
				if (fromUser == true) {
					pTextIncrement.setText(Float.toString(seekValues[progress]) + " %");
					}			
				}
			
			@Override
			public void onStartTrackingTouch(SeekBar seekBar) {
				// TODO Auto-generated method stub				
			}

			@Override
			public void onStopTrackingTouch(SeekBar seekBar) {
				// TODO Auto-generated method stub
				float base = Float.valueOf(pEditText.getText().toString());
				int progress = p_SeekBar.getProgress();
				float newValue =  (seekValues [progress] / 100 * base );
				pEditText.setText(Float.toString(newValue));
				p_SeekBar.setProgress(8);
				pTextIncrement.setText("");
			}
	});
    	SeekBar i_SeekBar = (SeekBar) v.findViewById(R.id.SeekBar_I);
    	SeekBar d_SeekBar = (SeekBar) v.findViewById(R.id.SeekBar_D);

    	return v;
	}
}
