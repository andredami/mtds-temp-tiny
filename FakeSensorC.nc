generic configuration FakeSensorC(){
  provides interface Read<float> as Sensor;
} 
implementation{
  components new FakeSensorP() as FakeSensor;
  Sensor = FakeSensor;

  components RandomC;
  FakeSensor.Random-> RandomC;
}