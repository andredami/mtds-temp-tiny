generic module FakeSensorC(){
	provides interface Read<uint16_t> as FakeRead;
	uses interface Random;
}
implementation{
	task void fakeMeasurement(){
		uint16_t measure = call Random.rand16() %50;
		signal FakeRead.readDone(SUCCESS,measure);
	}
	command error_t FakeRead.read(){
	//	dbg("default","%s | Node %d reading the sensor\n", sim_time_string(), TOS_NODE_ID);
		post fakeMeasurement();
		return SUCCESS;
	}

	

}