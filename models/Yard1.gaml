/**
* Name: Yard1
* Author: maciek
* Description: 
* Tag : Tag1, Tag2, TagN
*/

model Yard1

global torus: true {	
	int number_of_kids <- 30;
	//change 3
	file yard_block <- file("../includes/yard_block.shp");
	float agent_speed <- 0.000001 ;
	geometry shape <- envelope(yard_block);
	
	int current_hour update: ((cycle/3) / 60) mod 24 + 6;
	bool is_night <- true update: current_hour < 7 or current_hour > 20;
	
	init{
		create block from: yard_block with: [id::int(read ("id"))];
		create kid number: number_of_kids{
			block geom_block <- one_of(block);
			location <- any_location_in(geom_block);
			house <- geom_block.id;
			my_block<-geom_block;
		}
		
	}
	
	reflex fade_grid {
		ask kids_casual {
			do update_color;
		}
	}

}

species block {
	int id;
	aspect base {
		draw shape color: #blue;
	}
}

species kid skills: [moving]{
	float speed<-agent_speed;
	block my_block;
	int house;
	
	reflex move {
		do wander amplitude: 200 speed: speed*3;
	}

	reflex move_home when: is_night {
		do goto target: my_block speed: speed*5 ;
	}

	reflex move_yard when: ! is_night {
		//list<point> kids_list <- (kid collect each.location);
		point center <- sum(kid collect each.location)/length(kid);
		
		list<kid> kids_nearby <- kid at_distance (speed*20);
		if length(kids_nearby) >0 {
			point kids_direction <- sum(kids_nearby collect each.location)/length(kids_nearby);
			point vector <- self.location + (self.location - kids_direction);
			
			do goto target: vector speed: speed*3 ;
		
		}

		do goto target: center speed: speed*1 ;
	}
	
	reflex update_grid {
		ask kids_casual {
			if (self overlaps myself) {
				do seen;
			}
		}
	}	
	//reflex flocking when {
		
	//}
	aspect circle{
		draw circle(0.000009) color: rgb(100,255,100);
	}
}

grid kids_casual width: 50 height: 50 neighbors: 4 {
	int seen <- 0;
	rgb color <- #white;
	
	action seen{
		if (seen < 2550){
			seen <- seen+1;
		}
	}
	
	action update_color {
		if (seen=0){
			color <- #white;
		} else {
			
			color <- rgb(255,255-seen/10,255-seen/10);
			//seen<-seen-1;
		}	
	}
	
}

experiment Yard_play type: gui  {
	output {
		display map{
			grid kids_casual ;
			species block aspect: base;
			species kid aspect: circle;
		}
	}
}
