package reset.bluetoothchat.tab;

import android.app.Activity;
import android.content.Context;
import android.content.res.Configuration;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.InputMethodManager;
import android.widget.TextView;
import android.widget.Toast;
import android.widget.ToggleButton;
import android.widget.CompoundButton;
import android.widget.CompoundButton.OnCheckedChangeListener;

public class JoystickFragment extends Fragment {
	
	public static final String ARG_SECTION_NUMBER = "section_number";
	public static final String ARG_FRAGMENT_NAME = "fragment_name";
	BluetoothChat bActivity;
	
	
	public JoystickFragment() {
		// TODO Auto-generated constructor stub
	}
	
	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		View v;
    	v = inflater.inflate(R.layout.dualjoystick, container, false);
    	bActivity = ((BluetoothChat)getActivity());
    	DualJoystickView joystick;   
    	ToggleButton buttonLock = (ToggleButton) v.findViewById(R.id.buttonLock);

        joystick = (DualJoystickView) v.findViewById(R.id.dualjoystickView);
        
        JoystickMovedListener _listenerLeft = new JoystickMovedListener() {

            @Override
            public void OnMoved(int pan, int tilt) {
                    if (bActivity.isConnected()) {
	                    bActivity.sendMessage(getString(R.string.set_Left_X) + pan + '\n');
	                    bActivity.sendMessage(getString(R.string.set_Left_Y) + tilt + '\n');         
                    }
            }

            @Override
            public void OnReleased() {
            }
            
            public void OnReturnedToCenter() {
            };
        }; 

	    JoystickMovedListener _listenerRight = new JoystickMovedListener() {
	
	        @Override
	        public void OnMoved(int pan, int tilt) {
	                if (bActivity.isConnected()) {
		                bActivity.sendMessage(getString(R.string.set_Right_X) + pan + '\n');
	                    bActivity.sendMessage(getString(R.string.set_Right_Y) + tilt + '\n');    
	                }
	        }
	
	        @Override
	        public void OnReleased() {
	        }
	        
	        public void OnReturnedToCenter() {
	        };
	   }; 
        
        joystick.setOnJostickMovedListener(_listenerLeft, _listenerRight);
        
        buttonLock.setOnCheckedChangeListener(new OnCheckedChangeListener() {
        	
			@Override
			public void onCheckedChanged(CompoundButton arg0, boolean arg1) {
				// TODO Auto-generated method stub
				
				Activity activity = getActivity(); 
	            if (activity != null) {
	            	bActivity.mViewPager.setSwipingEnabled(!arg1);
	            	if (arg1) {
	            		bActivity.sendMessage(getString(R.string.manual_control));
	            	}
	            	else bActivity.sendMessage(getString(R.string.automatic_control));
	            }
			}
		});
    	return v;
	}
	
	public JoystickFragment getJoystickFragment() {
		return this;
	}
}
