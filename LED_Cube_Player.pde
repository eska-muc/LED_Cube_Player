/*
 * 8x8x8 LED Cube
 *
 * Loads files in the format of the DotMatrixJava editor. See: https://github.com/aguegu/DotMatrixJava 
 *
 * Copyrigth 2017 eskamuc http://github.com/eska-muc
 *
 */
 
import java.util.Collections;
import java.util.List;
 
float BLOCKWIDTH = 40;
Cube cube;
float rotx = PI/4;
float roty = PI/4;
List<Frame> frameList = new ArrayList<Frame>();
int currentFrame = 0;
int maxFrames;
byte bitcheck[] = { (byte)1,(byte)2,(byte)4,(byte)8,(byte)16,(byte)32,(byte)64,(byte)128 };
boolean debug = false;
boolean singlestep = true;
String currentFile = "<none>";
boolean fileLoaded = false;
 
void setup() {
  size(1024,768,P3D);  
  cube = new Cube();    
}

void draw() {
  if (!singlestep) {
    currentFrame++;
    if (currentFrame>=maxFrames) {
      currentFrame=0;
    }
    cube.initCube();
  }
  background(64,64,64);
  fill(100,100,100);
  textSize(24);
  text("LED Cube Player - Stefan Kühnel 2017",10,30);
  textSize(14);
  text("Pressh 'h' to print usage info in console. Current file: "+currentFile,10,height-20);  
  translate(width/2,height/2);  
  rotateX(rotx);
  rotateY(roty);
  cube.draw();
  
}

void mouseDragged() {
  float rate = 0.01;
  rotx += (pmouseY-mouseY) * rate;
  roty += (mouseX-pmouseX) * rate;
}
 
void keyPressed() {
  if (key=='L'||key=='l') {
    // export
    selectInput("Load .dat file","loadFile");
  } else if ((key == 'N' || key=='n') && singlestep && fileLoaded) {
    currentFrame = currentFrame + 1;
    if (currentFrame >= maxFrames)  {
      currentFrame = 0;
    }    
    cube.initCube();
  } else if (key == 'Q' || key=='q') {
    exit();
  } else if (key == 'D' || key=='d') {
    debug = !debug;
    System.err.printf("Debug output %s\n",debug?"enabled":"disabled");    
  } else if (key == 'S' || key=='s') {
    if (fileLoaded) {
      singlestep = !singlestep;
    } else {
      System.err.println ("No File");
    }
  }else if (key == 'H' || key=='h') {
    usage();
  }
}

void usage() {
  System.out.println ("LED Cube Player - (C) 2017 Stefan Kühnel");
  System.out.println ();
  System.out.println ("See: https://github.com/eska-muc");
  System.out.println ();
  System.out.println ("Keys: l - load .dat file)");
  System.out.println ("      n - next frame (in singlestep mode)");
  System.out.println ("      h - print this message");
  System.out.println ("      s - toggle single step mode");
  System.out.println ("      d - toggle debug output on console");
  System.out.println ("      q - quit");  
}

void loadFile(File selected) {
  
  if (selected != null && selected.exists() && selected.isFile() && selected.canRead()) {
  
    // Stop animation
    if (!singlestep) {
     singlestep = true; 
    }
   
    if (!frameList.isEmpty()) {
      frameList.clear();
    }
    
    byte b[] = loadBytes(selected.getPath());
    int len = b.length;
    int frames = len/72;
    System.out.println("File   : "+selected.getPath());
    System.out.println("Length : "+len);
    System.out.println("Frames : "+frames);
    maxFrames = frames;
    for (int i= 0;i<frames;i++) {
      byte[] frameBuffer = new byte[64];
      System.arraycopy(b,i*72+8,frameBuffer,0,64);
      frameList.add(new Frame(frameBuffer));
    }       
    currentFrame = 0;
    singlestep=false;
    currentFile=selected.getName();
    cube.initCube();
  } else {
    System.err.println ("Cannot access file.");
    fileLoaded=false;
  }
  
}
 
 
class LED {
  
  boolean status = false;
  
  void setOn() {
    status = true;
  }
  
  void setOff() {
    status = false;
  }
  
  void set(boolean status) {
    this.status = status;
  }
    
  boolean get() {
    return status;
  }
  
  void draw() {
     if (status) {
       fill(255,10,10);
     } else {
       fill(25,10,10);
     }
     noStroke();
     sphere(BLOCKWIDTH/8);         
  }
  
}

class Frame {
  byte bytes[];
  
  
  Frame(byte buffer[]) {
     bytes = new byte[buffer.length];
     System.arraycopy(buffer,0,bytes,0,buffer.length);
     if (debug) {
       for (int i=0;i<buffer.length;i++) {
         System.out.printf("%02X ",buffer[i]);
         if (((i+1)%8)==0) {
           System.out.println();
         }       
       }
     }
  }
  
  boolean get(int x,int y, int z) {
    //int index = 64 * z + 8 * y + x;
    int byteNo = x*8+y;
    byte b = bytes[byteNo];
    boolean retVal = ((b&bitcheck[z])==bitcheck[z]); 
    if (debug) {
      System.out.printf ("Byte[%d]: %02X X: %d Y: %d Z: %d => %c\n",byteNo,b,x,y,z,retVal?'T':'F');
    }
    return retVal;
  }    
}

class Cube {
  
  LED[][][] cube;
  
  Cube() {
    cube = new LED[8][8][8]; 
    initCube();
  }
  
  void initCube() {
    for (int x=0;x<8;x++) {
      for (int y=0;y<8;y++) {
        for (int z=0;z<8;z++) {
          cube[x][y][z] = new LED();            
            if (frameList.size()>0) {              
              cube[x][y][z].set(frameList.get(currentFrame).get(x,y,z));
            } else {
              cube[x][y][z].setOff();
            }
        }
      }
    }
  }
  
  void draw() {     
    for(int x=0;x<8;x++) {
      for (int y=0;y<8;y++) {
        for (int z=0;z<8;z++) {           
          pushMatrix();
          translate(BLOCKWIDTH*(4-x),BLOCKWIDTH*(4-y),BLOCKWIDTH*(4-z));          
          cube[x][y][z].draw();           
          popMatrix();              
         }         
       }
     }     
   }
 }