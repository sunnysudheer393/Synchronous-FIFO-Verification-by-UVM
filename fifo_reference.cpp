#include <svdpi.h>
#include <iostream>
#include <queue>
using namespace std;

queue<int> my_fifo;
const int DEPTH = 8;
bool pending_read = false;
int last_expected_data = -1;
int last_data = -1;
extern "C" {
    
    //funtion to push/write into fifo/c++ model
    void cpp_fifo_write(int data) {
        my_fifo.push(data);
        cout<<"Written to FIFO: "<< data <<endl;
    }

    //fntion to read from fifo/c++ model
    int cpp_fifo_read(){
        if(my_fifo.empty()) {
            cout<<"FIFO is Empty!"<<endl;
            return -1;
        } else {
            int data = my_fifo.front();
            my_fifo.pop();
            cout<<"Read from FIFO: "<<data<<endl;
            return data;
        }
    }

    int cpp_fifo_size(){
        return my_fifo.size();
    }
}

// extern "C" {
//     //scoreboard function entire operation
//     int c_fifo_scoreboard(int wr_en, int rd_en, int data_in, int data_out, int full, int empty){
//         int current_status = -1;
        
       
//         if(pending_read){
//             if(last_expected_data!=data_out){
//                     cout<<"[C++ Scoreboard] ERROR: Data MISMATCH! Expected: "<<last_expected_data<<" , Received: "<<data_out<<endl;
//                     current_status = 0;
//                     //return 0;
//                 } else {
//                     cout<<"[C++ Scoreboard] SUCCESS: Data MATCH! Expected and Received: "<<data_out<<endl;
//                     current_status = 1;
//                     //return 1;
//                 }
//                 pending_read = false;
//         }

//         //Handle Write Operations//Handle Write Operations
//         if(wr_en && !full){
//             my_fifo.push(data_in);
//             cout<<"[C++ Scoreboard]: Written to FIFO: "<<data_in<<endl;
//           //return 1;
//         }


//         //Handle Read Opeartions
//          if(rd_en && !empty){
//             if(!my_fifo.empty()){
//                 last_expected_data = my_fifo.front();
//                 //last_data = data_out;
//                 my_fifo.pop();
//                 pending_read = true;
//             }
//         }

//         return current_status;
//     }
// }