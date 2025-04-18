package com.example.demo;

import java.util.HashMap;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.ComponentScan;

@MapperScan("com.example.demo.mapper")
@SpringBootApplication
public class DemoApplication {

	public static void main(String[] args) {
		HashMap<Object,Object> map = new HashMap<>();
		SpringApplication.run(DemoApplication.class, args);
	}

}
