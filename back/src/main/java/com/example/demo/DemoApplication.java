package com.example.demo;

import java.util.HashMap;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class DemoApplication {

	public static void main(String[] args) {
		HashMap<Object,Object> map = new HashMap<>();
		SpringApplication.run(DemoApplication.class, args);
	}

}
