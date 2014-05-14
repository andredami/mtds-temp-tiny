module TmpCollectorP {
	provides interface Read<uint16_t> as TmpCollector;
	provides interface StdControl;
	uses interface Read<uint16_t> as TmpRead;
	uses interface Timer<TMilli> as ReadTimer;
}
implementation{

	uint16_t measures[6];
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
		uint16_t total=0;
		for(;i<6;i++){
			total=total+measures[i];
		}
		signal TmpCollector.readDone(SUCCESS,(uint16_t)(total/6));
	}

	command error_t TmpCollector.read(){
		post computeAverage();
		return SUCCESS;
	}
	
	event void ReadTimer.fired(){
		call TmpRead.read();
	}

	event void TmpRead.readDone(error_t err,uint16_t measure){
		if(err == SUCCESS){
			current_index++;
			current_index = current_index % 6;
			measures[current_index]=measure;
		}
	}

	
}