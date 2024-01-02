

unsigned char port_byte_in(unsigned short port){
  unsigned char result;
  //we map the port value into the dx register
  // port is then loaded from dx to al in
  // now value of al regisrer is stored in result variable
  __asm__("in %%dx,%%al":"=a"(result):"d"(port));
  return result;
}
void port_byte_out(unsigned short port, unsigned char data){
  // here we dont have any result to return 
  __asm__("out %%al,%%dx" : : "a"(data));
}

