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
const unsigned char world[3][4] = { { 10, 0, 1, 7 }, { 2, 10, 0, 3 }, { 6, 8,
		7, 6 } };

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

void moveToMostFertileLocation(Ant *ant) {
	int east_fertility, south_fertility;

	int new_column = (ant->position.col + 1) % 4;
	int new_row = (ant->position.row + 1) % 3;

	east_fertility = world[ant->position.row][new_column];
	south_fertility = world[new_row][ant->position.col];

	if (east_fertility > south_fertility) {
		ant->position.col = new_column;
	} else {
		ant->position.row = new_row;
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
	for (int i = 0; i < 2; ++i) {
		int fertility = world[ant.position.row][ant.position.col];
		queen <: fertility;

		char command;
		queen :> command;

		if (command == 'H') {
			ant.food += fertility;
			printf("Food harvested: %d\n", ant.food);
		} else {
			for (int i = 0; i < 2; ++i) {
				moveToMostFertileLocation(&ant);
			}
		}
	}
}


void queen_ant(int row, int col, chanend worker_1, chanend worker_2) {
    int totalHarvest = 0;
    int fertility_1, fertility_2;

    for (int i = 0; i < 2; ++i) {

        worker_1 :> fertility_1;
        worker_2 :> fertility_2;

        if (fertility_1 > fertility_2) {
            worker_1 <: 'H';
            worker_2 <: 'M';

            totalHarvest += fertility_1;
        } else {
            worker_1 <: 'M';
            worker_2 <: 'H';

            totalHarvest += fertility_2;
        }
    }
    printf("Total harvest by queen: %d", totalHarvest);
}

/*
 * main function containing only par block
 * passes start positions to ants
 */
int main(void) {
chan worker_1, worker_2;
par
{
	ant(0, 1, worker_1);
	ant(1, 0, worker_2);
	queen_ant(1, 1, worker_1, worker_2);
}

return 0;
}
