/* set a single pixel on the screen at x,y
 * x in [0,319], y in [0,239], and colour in [0,65535]
 */
void write_pixel(int x, int y, short colour) {
  volatile short *vga_addr=(volatile short*)(0x08000000 + (y<<10) + (x<<1));
  *vga_addr=colour;
}

/* use write_pixel to set entire screen to black (does not clear the character buffer) */
void clear_screen() {
  int x, y;
  for (x = 0; x < 320; x++) {
    for (y = 0; y < 240; y++) {
	  write_pixel(x,y,0);
	}
  }
}

/* write a single character to the character buffer at x,y
 * x in [0,79], y in [0,59]
 */
void write_char(int x, int y, char c) {
  // VGA character buffer
  volatile char * character_buffer = (char *) (0x09000000 + (y<<7) + x);
  *character_buffer = c;
}

void PrintStartingScreen() {

    clear_screen();
	char *a = "PRESS START";
	int i=0;
	for(i=0; i < strlen(a); i++)
	{
		write_char(20+i,20,a[i]);
	}
    a[0] = '\0';
	
    return ;
}

void Machineison()
{
	clear_screen();
	char *a = "MACHINE IS ON, PLEASE STAY BACK";
	int i=0;
	for(i=0; i < strlen(a); i++)
	{
		write_char(20+i,20,a[i]);
	}
	 a[0] = '\0';
	return ;
	
}

void Machineisoff()
{
	clear_screen();
	char *a = "MACHINE IS OFF, PRESS START TO START AGAIN";
	int i=0;
	for(i=0; i < strlen(a); i++)
	{
		write_char(20+i,20,a[i]);
	}
	a[0] = '\0';
	return ;
}