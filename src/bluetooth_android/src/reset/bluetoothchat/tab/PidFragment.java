package reset.bluetoothchat.tab;

import android.app.Activity;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.View.OnClickListener;
import android.widget.Button;
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
		View v;
		final BluetoothChat bActivity = ((BluetoothChat)getActivity());
    	v = inflater.inflate(R.layout.pid_conf, container, false);
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
    	return v;
	}
}
