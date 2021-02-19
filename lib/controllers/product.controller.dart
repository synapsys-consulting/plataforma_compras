class ProductController {
  int numUnits = 0;

  ProductController() {
    this.numUnits = 0;
  }
  ProductController.initialization(int value){
    this.numUnits = value;
  }
  void increment() {
    numUnits += 1;
  }
  void decrement() {
    numUnits -= 1;
  }
}