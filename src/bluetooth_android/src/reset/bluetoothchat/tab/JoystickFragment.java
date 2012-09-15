package reset.bluetoothchat.tab;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

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
    	final TextView txtX1, txtY1;
        final TextView txtX2, txtY2;
        DualJoystickView joystick; 
    	txtX1 = (TextView) v.findViewById(R.id.TextViewX1);
        txtY1 = (TextView) v.findViewById(R.id.TextViewY1);
        
        txtX2 = (TextView) v.findViewById(R.id.TextViewX2);
        txtY2 = (TextView) v.findViewById(R.id.TextViewY2);

        joystick = (DualJoystickView) v.findViewById(R.id.dualjoystickView);
        
        JoystickMovedListener _listenerLeft = new JoystickMovedListener() {

            @Override
            public void OnMoved(int pan, int tilt) {
                    txtX1.setText(Integer.toString(pan));
                    txtY1.setText(Integer.toString(tilt));
                    bActivity.sendMessage(getString(R.string.set_Left_X) + pan + '\n');
                    bActivity.sendMessage(getString(R.string.set_Left_Y) + tilt + '\n');                   
            }

            @Override
            public void OnReleased() {
                    txtX1.setText("released");
                    txtY1.setText("released");
            }
            
            public void OnReturnedToCenter() {
                    txtX1.setText("stopped");
                    txtY1.setText("stopped");
            };
        }; 

	    JoystickMovedListener _listenerRight = new JoystickMovedListener() {
	
	        @Override
	        public void OnMoved(int pan, int tilt) {
	                txtX2.setText(Integer.toString(pan));
	                txtY2.setText(Integer.toString(tilt));
	                bActivity.sendMessage(getString(R.string.set_Right_X) + pan + '\n');
                    bActivity.sendMessage(getString(R.string.set_Right_Y) + tilt + '\n');    
	        }
	
	        @Override
	        public void OnReleased() {
	                txtX2.setText("released");
	                txtY2.setText("released");
	        }
	        
	        public void OnReturnedToCenter() {
	                txtX2.setText("stopped");
	                txtY2.setText("stopped");
	        };
	   }; 
        
        joystick.setOnJostickMovedListener(_listenerLeft, _listenerRight);
    	return v;
	}

}
