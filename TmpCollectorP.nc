module TmpCollectorP {
	provides interface Read<float> as TmpAverage;
	provides interface StdControl;
	uses interface Read<float> as TmpRead;
	uses interface Timer<TMilli> as ReadTimer;
}
implementation{
	bool ready=FALSE;
	float measures[6];
	uint8_t current_index;

	command error_t StdControl.start(){
		dbg("default","%s | Node %d started tmp collector\n", sim_time_string(), TOS_NODE_ID);
		call ReadTimer.startPeriodic(5000);
		return SUCCESS;
	}

	command error_t StdControl.stop(){
		call ReadTimer.stop();
		return SUCCESS;
	}

	task void computeAverage(){
		uint8_t i=0;
		float total=0;
		for(;i<6;i++){
			total=total+measures[i];
		}
		signal TmpAverage.readDone(SUCCESS, total/6.0);
	}

	command error_t TmpAverage.read(){
		if(!ready){
			return FAIL;
		}
		post computeAverage();
		return SUCCESS;
	}
	
	event void ReadTimer.fired(){
		call TmpRead.read();
	}

	event void TmpRead.readDone(error_t err,float measure){
		if(err == SUCCESS){
			current_index++;
			current_index = current_index % 6;
			measures[current_index]=measure;
			if(!ready && current_index==0){
				ready=TRUE;
			}
		}
	}

	
}