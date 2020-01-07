# Introduction

## Lab1_git

| 模块（Module）    | Introduction                                                 |
| ----------------- | ------------------------------------------------------------ |
| CRC               | Implement two CRC modules, 1 uses Definition, another is based on LFSR |
| Divide_with Shift | calculate divide with shift operations                       |
| Global_Counter    | Three Timer which use a Global Counter                       |
| LFSR              | Linear feedback Register                                     |
| LRU               | Arbiter based on least-recent-used(LRU)                      |

## Lab2

| 模块（Module）    | Introduction                                               |
| ----------------- | ---------------------------------------------------------- |
| Sequence Detector | Sequence Detector based on Shift reg(extremely simple one) |
| SquareRoot        | Calculate Square Root based on Shift                       |
| **Optimal_place** | **Implement Breath First Search with Verilog**             |


**Optimal_place**

The input is an 8*8 array with (0,1,2); 0: empty, 1: reg, and 2: combination logic. This module is to find the point to place the Clock source(if possible) , which has minimum distance to all the registers.

In my implementation, The maximum time takes to calculate the distance is O(N^2): 64\*64\*4 + C(constant time);

The process to solve this problem is calculate all node of 0's distance. For each Node -> walk(get next node, x-1, x+1, y-1, y+1) and then check if they are reg(value =1). If they haven't checked, set vld and record distance, else ignore.

So I designed a sync_fifo, some functions like walk and judge. The **hierarchy** of the module is

**tb** 

**-> optimal_place.v**  (read in.txt to an reg_array, return array value to BFS search, for each node of 0 perform BFS search)

​	**-> BFS search** (perform BFS search for each node and calculate the total cost)

​		**-> sync_fifo**(a queue to assist BFS search)

最小路径-广度优先搜索，

读入8*8的阵列，0代表空，1代表寄存器，2代表组合逻辑，只有0能摆放时钟源，要计算出时钟源摆放的最优位置（到各寄存器的距离最小） 。 使用广度优先搜索

首先是设计单个node的广度优先搜索，在load_start_node时录入起始点，然后每拍产生一个其周围的点，或是合理的（没被检索过，不越界，或者是0，1）那就加入队列，每次从队列中取出一个点来计算他的周围点或者距离直到队列空。

复杂度应该按O(N^2)来算， 最多64个node需要BFS, 每个点做64*4次+64个clock算总cost.

## Lab3
Asyc_FIFO


## Lab5 Simplified AXI

## Phase1
Cardinal Router

## Phase2
Gold Processor with Cardinal Router


