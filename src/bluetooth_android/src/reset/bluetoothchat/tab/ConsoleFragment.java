package reset.bluetoothchat.tab;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.TextView;


public  class ConsoleFragment extends Fragment {
	
	public static final String ARG_SECTION_NUMBER = "section_number";
	public static final String ARG_FRAGMENT_NAME = "fragment_name";
    // Layout Views
    private ListView mConversationView;
    private EditText mOutEditText;
    private Button mSendButton;
    
    public ConsoleFragment() {
		// TODO Auto-generated constructor stub
	}
    
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
    		Bundle savedInstanceState) {
    	// TODO Auto-generated method stub
    	View v = inflater.inflate(R.layout.main, container, false);
    	final BluetoothChat bActivity = ((BluetoothChat)getActivity());
	   	 // Initialize the compose field with a listener for the return key
        mOutEditText = (EditText) v.findViewById(R.id.edit_text_out);
        mOutEditText.setOnEditorActionListener(bActivity.getmWriteListener());

        // Initialize the send button with a listener that for click events
        mSendButton = (Button) v.findViewById(R.id.button_send);
        mSendButton.setOnClickListener(new OnClickListener() {
            public void onClick(View v) {
                // Send a message using content of the edit text widget
                String message = mOutEditText.getText().toString();
                int sent = bActivity.sendMessage(message);
                // In case the message was successfully sent, clear the edit text field
                if (sent == 1) mOutEditText.setText("");
            }
        });
        
        // Initialize the conversation view
        mConversationView = (ListView) v.findViewById(R.id.in);
        mConversationView.setAdapter(bActivity.getmConversationArrayAdapter());
    	return v;
    }	
}
