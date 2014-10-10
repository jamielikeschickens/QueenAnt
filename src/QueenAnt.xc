/*
 * parallelAnts.xc
 *
 *  Created on: Oct 3, 2014
 *      Author: Freddie
 */

#include <stdio.h>
#include <platform.h>

/*
 * establish 2D array for world
 */
const unsigned char world[3][4] = {{10,0,1,7},{2,10,0,3},{6,8,7,6}};

/*
 * structure for the position of an ant
 */
typedef struct Position {
    int row;
    int col;
} Position;

/*
 * structure for an ant incl its position & food value
 */
typedef struct Ant {
    Position position;
    int food;
} Ant;

/*
 * move east function
 * arguments: 1 x ant pointer
 */
void moveEast(Ant *ant) {
    if (ant->position.col == 3) {
        ant->position.col = 0;
    } else {
        ant->position.col += 1;
    }
}

/*
 * move south function
 * arguments: 1 x ant pointer
 */
void moveSouth(Ant *ant) {
    if (ant->position.row == 2) {
        ant->position.row = 0;
    } else {
        ant->position.row += 1;
    }
}

/*
 * print ant info function
 * arguments: 1 x ant
 */
void printAntInfo(Ant ant) {
    printf("Food items: %d\n", ant.food);
}

/*
 *
 */
void ant(int row, int col, chanend queen) {
    Ant ant;
    ant.position.row = row;
    ant.position.col = col;
    ant.food = 0;
    for (int i=0; i < 2; ++i) {
            int fertility = world[ant.position.row][ant.position.col];
            queen <: fertility;

            char command;
            queen :> command;

            if (command == 'H') {
                ant.food += fertility;
                queen <: fertility;
                printf("Food harvested: %d\n", ant.food);
            } else {

                for (int i=0; i < 2; ++i) {
                    int east_fertility, south_fertility;

                    if (ant.position.col == 3) {
                        east_fertility = world[ant.position.row][0];
                    } else {
                        east_fertility = world[ant.position.row][ant.position.col + 1];
                    }

                    if (ant.position.row == 2) {
                        south_fertility = world[0][ant.position.col];
                    } else {
                        south_fertility = world[ant.position.row + 1][ant.position.col];
                    }

                    if (east_fertility > south_fertility) {
                        moveEast(&ant);
                    } else {
                        moveSouth(&ant);
                    }
                }

                printf("Location: (%d, %d)\n", ant.position.row, ant.position.col);

            }
    }
}

void queen_ant(int row, int col, chanend worker_1, chanend worker_2, chanend super_queen) {
    int total_harvest = 0;

    for (int i=0; i < 2; ++i) {
            int worker_1_fertility, worker_2_fertility;
            worker_1 :> worker_1_fertility;
            worker_2 :> worker_2_fertility;


            if (worker_1_fertility > worker_2_fertility) {
                super_queen <: worker_1_fertility;
                char command;
                super_queen :> command;
                if (command == 'H') {
                    total_harvest += worker_1_fertility;
                    worker_2 <: 'M';
                } else {
                    worker_1 <: 'M';
                    worker_2 <: 'M';
                }
            } else {
                super_queen <: worker_2_fertility;
                char command;
                super_queen :> command;

                if (command == 'H') {
                    total_harvest += worker_2_fertility;
                    worker_1 <: 'M';
                } else {
                    worker_1 <: 'M';
                    worker_2 <: 'M';
                }
            }
            printf("Total harvest: %d\n", total_harvest);
    }
}

void super_queen_ant(chanend queen_1, chanend queen_2) {
    for (int i=0; i < 2; ++i) {
            int fertility1, fertility2;
            queen_1 :> fertility1;
            queen_2 :> fertility2;
            if (fertility1 > fertility2) {
                queen_1 <: 'H';
                queen_2 <: 'M';
                printf("Queen 1 picked\n");
            } else {
                queen_1 <: 'M';
                queen_2 <: 'H';
                printf("Queen 2 picked\n");
            }
    }
}

/*
 * main function containing only par block
 * passes start positions to ants
 */
int main(void) {
    chan worker_1, worker_2, worker_3, worker_4, queen_1, queen_2;
    par {
        ant(0, 1, worker_1);
        ant(1, 0, worker_2);
        queen_ant(1, 1, worker_1, worker_2, queen_1);
        ant(0, 1, worker_3);
        ant(1, 0, worker_4);
        queen_ant(1 ,1, worker_3, worker_4, queen_2);
        super_queen_ant(queen_1, queen_2);
    }

    return 0;
}
