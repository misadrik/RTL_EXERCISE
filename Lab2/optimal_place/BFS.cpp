#include <iostream>
#include <fstream>
using namespace std;

#include <queue>
#define MAX_NUM 8
#define COL_NUM 8
#define LIN_NUM 8

#include <cstring>

int matrix[MAX_NUM][MAX_NUM];

int cost[MAX_NUM][MAX_NUM];

int n;

int total_reg;
 
typedef struct Node{
    int x;
    int y;
    Node(){x=0;y=0;}
    Node(int x, int y){
        this -> x = x;
        this -> y = y;
    }
}node;

bool judge(node node){
    if(node.x < 0 || node.x > COL_NUM - 1) return false; //out of range
    if(node.y < 0 || node.y > LIN_NUM - 1) return false;

    if(matrix[node.x][node.y] == 2) return false; // comb or

    return true;
}

node walk(node start, int dir){
    if(dir == 0){
        return node(start.x, start.y - 1);
    }
    if(dir == 1){
        return node(start.x, start.y + 1);
    }
    if(dir == 2){
        return node(start.x - 1, start.y);
    }
    if(dir == 3){
        return node(start.x + 1, start.y);
    }
}

void bfs(node start){
    queue <node> q;
    q.push(start);
    node next;

    while(!q.empty()){
      node p = q.front();
      q.pop();
 
      for(int i = 0; i < 4; i++){
        next = walk(p,i);
        if(cost[next.x][next.y] < 0 && judge(next)){
			cost[next.x][next.y] = cost[p.x][p.y] + 1;
			if(matrix[next.x][next.y] != 1)
            	q.push(next);    
        }
      }  
    }
}



int search_one_grid(int x,int y){
	int total_cost = 0;
	int reg_num = 0;
	node start(x,y);
    memset(cost, -1, sizeof(cost));
    cost[start.x][start.y] = 0;	
    bfs(start);
//    printCost(); 
    for(int i = 0; i < LIN_NUM; i++){
        for(int j = 0; j < COL_NUM; j++){
			if((matrix[i][j] == 1) && (cost[i][j]!= -1)){
				total_cost += cost[i][j];
				reg_num++;
			}
				
		}
	}
	if(reg_num == total_reg)
		return total_cost;
	else
		return -1;
	
}

 
int main(){
	char c;
    int i;
    int j;
   
    ifstream infile;
    infile.open("input.txt");
    i = j = 0;
    while(1)
    {
        if(j == 8){
            j = 0;
            i++;
            cout << endl;
        }
        infile>>c;
        matrix[i][j] = c-48;
        cout<< matrix[i][j]<<' ';
        if(c-48 == 1)
        	total_reg++;
        j++;
        
        if(i == 7 && j == 8) break;
    }
    cout <<endl;
	
//    node start(1,2);
//    memset(cost, -1, sizeof(cost));
//    cost[start.x][start.y] = 0;	
//    bfs(start);
	int cost_min = 100000;
	int grid_cost= -1;
	int x_min = -1;
	int y_min = -1;
    for(int i = 0; i < LIN_NUM; i++){
        for(int j = 0; j < COL_NUM; j++){
        	if(matrix[i][j] == 0){
        		grid_cost = search_one_grid(i,j);
//				cout<<i<<", "<<j<<" "<<grid_cost<<endl;
				if((grid_cost!= -1)&& (grid_cost < cost_min)){
					cost_min = grid_cost;
					x_min = i;
					y_min = j;
				}
			}

		}
	}
	cout<<"minimum cost is:" <<cost_min<<" @("<<x_min<<", "<<y_min<<")"<<endl;
	
    return 0;
}
