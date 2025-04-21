package com.example.demo.mapper;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.demo.entity.AboutListVO;
import com.example.demo.entity.DoneListVO;
import com.example.demo.entity.SubmitListVO;
import com.example.demo.entity.TodoListVO;
import org.apache.ibatis.annotations.*;

import java.util.Map;


/**
 * @author chonghui. tian
 * date 2025/4/18 11:47
 * description
 */
@Mapper
public interface TaskMapper {

    @Select("<script>" +
            "SELECT " +
            "  (SELECT COUNT(DISTINCT ta.task_id) " +  // 待办数：独立子查询，避免关联历史表
            "   FROM flw_task_actor ta " +
            "   WHERE ta.actor_id = #{userId} " +
            "     <if test='tenantId != null'> AND ta.tenant_id = #{tenantId} </if>" +
            "  ) AS todo, " +
            "  COUNT(DISTINCT CASE WHEN ht.perform_type = 1 THEN hta.task_id END) AS done, " +  // 已办数
            "  COUNT(DISTINCT CASE WHEN ht.perform_type = 0 THEN hta.task_id END) AS submit, " + // 提交数
            "  COUNT(DISTINCT CASE WHEN ht.perform_type = 9 THEN hta.task_id END) AS about " +   // 抄送数
            "FROM flw_his_task_actor hta " +
            "JOIN flw_his_task ht ON hta.task_id = ht.id " +  // 历史表联查
            "WHERE hta.actor_id = #{userId} " +
            "  <if test='tenantId != null'> AND hta.tenant_id = #{tenantId} </if>" +
            "</script>")
    Map<String, Long> taskCount(@Param("userId") String userId, @Param("tenantId") String tenantId);

    @Select("<script>" +
            "SELECT " +
            "  hi.id AS instanceId, " +
            "  ta.task_id, " +
            "  ei.process_name, " +
            "  hta.actor_name AS startName, " +
            "  ht.finish_time AS submitTime, " +
            "  t.task_name AS currentNode, " +
            "  t.create_time AS arriveTime, " +
            "  hi.instance_state AS taskState " +
            "FROM flw_task_actor ta " +
            "JOIN flw_task t ON ta.task_id = t.id " +
            "LEFT JOIN flw_his_task ht ON ta.instance_id = ht.instance_id AND ht.parent_task_id = 0 " +
            "LEFT JOIN flw_his_task_actor hta ON ht.id = hta.task_id " +
            "LEFT JOIN flw_his_instance hi ON t.instance_id = hi.id " +
            "LEFT JOIN flw_ext_instance ei ON t.instance_id = ei.id " +
            "WHERE ta.actor_id = #{userId} " +
            "<if test='tenantId != null'> AND t.tenant_id = #{tenantId} </if>" +
            "ORDER BY t.create_time DESC" +
            "</script>")
    IPage<TodoListVO> todoList(@Param("userId") String userId, @Param("tenantId") String tenantId, Page page);

    @Select("<script>" +
            "SELECT" +
            "  ei.id AS instanceId," +
            "  a.task_id, ei.process_name," +
            "  (SELECT hta_start.actor_name " +
            "   FROM flw_his_task ht_start " +
            "   JOIN flw_his_task_actor hta_start ON ht_start.id = hta_start.task_id " +
            "   WHERE ht_start.instance_id = b.instance_id " +
            "     AND ht_start.parent_task_id = 0 " +
            "   LIMIT 1) AS startName, " +
            "  b.task_name AS currentNode, " +
            "  b.create_time AS startTime, " +
            "  b.finish_time, b.duration, b.task_state " +
            "FROM flw_his_task_actor a " +
            "JOIN flw_his_task b ON a.task_id = b.id " +
            "LEFT JOIN flw_ext_instance ei ON b.instance_id = ei.id " +
            "WHERE a.actor_id = #{userId} " +
            "  AND b.perform_type = 1 " +
            "<if test='tenantId != null'> AND b.tenant_id = #{tenantId} </if>" +
            "ORDER BY b.create_time DESC" +
            "</script>")
    IPage<DoneListVO> doneList(@Param("userId") String userId, @Param("tenantId") String tenantId, Page page);

    @Select("<script>" +
            "SELECT" +
            "    hi.id AS instanceId," +
            "    ht.id AS taskId," +
            "    ei.process_name," +
            "    hta.actor_name AS startName," +
            "    hi.create_time AS submitTime," +
            "    hi.end_time AS endTime," +
            "    hi.current_node_name AS currentNode," +
            "    hi.instance_state AS taskState," +
            "    CASE" +
            "        WHEN hi.end_time IS NOT NULL THEN (" +
            "            SELECT SUM(t.duration)" +
            "            FROM flw_his_task t" +
            "            WHERE t.instance_id = hi.id" +
            "        )" +
            "        ELSE TIMESTAMPDIFF(SECOND, ht.create_time, NOW()) * 1000" +
            "    END AS duration " +
            "FROM flw_his_task_actor hta " +
            "JOIN flw_his_task ht ON hta.task_id = ht.id " +
            "JOIN flw_his_instance hi ON ht.instance_id = hi.id " +
            "LEFT JOIN flw_ext_instance ei ON ht.instance_id = ei.id " +
            "WHERE ht.parent_task_id = 0 " +
            "<if test='userId != null'> AND hta.actor_id = #{userId} </if>" +
            "<if test='tenantId != null'> AND hi.tenant_id = #{tenantId} </if>" +
            "ORDER BY hi.create_time DESC" +
            "</script>")
    IPage<SubmitListVO> submitList(@Param("userId") String userId, @Param("tenantId") String tenantId, Page page);


    @Select("<script>" +
            "SELECT" +
            "  hi.id AS instanceId, " +
            "  a.task_id, " +
            "  ei.process_name, " +
            "  (SELECT hta.actor_name " +
            "   FROM flw_his_task ht_start " +
            "   JOIN flw_his_task_actor hta ON ht_start.id = hta.task_id " +
            "   WHERE ht_start.instance_id = b.instance_id " +
            "     AND ht_start.parent_task_id = 0 " +
            "   LIMIT 1) AS startName, " +
            "  hi.create_time AS submitTime, " +
            "  b.task_name AS currentNode, " +
            "  hi.instance_state AS taskState, " +
            "  CASE " +
            "    WHEN hi.end_time IS NOT NULL THEN (" +
            "      SELECT SUM(t.duration) " +
            "      FROM flw_his_task t " +
            "      WHERE t.instance_id = hi.id " +
            "    ) " +
            "    ELSE TIMESTAMPDIFF(SECOND, hi.create_time, NOW()) * 1000 " +
            "  END AS duration, " +
            "  b.finish_time AS endTime " +
            "FROM flw_his_task_actor a " +
            "JOIN flw_his_task b ON a.task_id = b.id " +
            "JOIN flw_his_instance hi ON b.instance_id = hi.id " +
            "LEFT JOIN flw_ext_instance ei ON b.instance_id = ei.id " +
            "WHERE a.actor_id = #{userId} " +
            "  AND a.weight = 6 " +
            "<if test='tenantId != null'> AND hi.tenant_id = #{tenantId} </if>" +
            "ORDER BY hi.create_time DESC" +
            "</script>")
    IPage<AboutListVO> aboutList(@Param("userId") String userId, @Param("tenantId") String tenantId, Page page);

}
