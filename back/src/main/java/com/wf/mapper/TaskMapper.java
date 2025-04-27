package com.wf.mapper;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.wf.entity.AboutListVO;
import com.wf.entity.DoneListVO;
import com.wf.entity.SubmitListVO;
import com.wf.entity.TodoListVO;
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
            "  (SELECT COUNT(DISTINCT ta.task_id) " +
            "   FROM flw_task_actor ta " +
            "   INNER JOIN flw_task t ON ta.task_id = t.id " +
            "   WHERE ta.actor_id = #{userId} " +
            "     AND t.task_type = 1 " +
            "     <if test='tenantId != null'> AND ta.tenant_id = #{tenantId} </if>" +
            "  ) AS todo, " +
            "  IFNULL(SUM(CASE WHEN ht.task_type != 0 THEN 1 ELSE 0 END), 0) AS done, " +
            "  IFNULL(SUM(CASE WHEN ht.task_type = 0 THEN 1 ELSE 0 END), 0) AS submit, " +
            "  IFNULL(SUM(CASE WHEN hta.weight = 6 THEN 1 ELSE 0 END), 0) AS about " +
            "FROM flw_his_task_actor hta " +
            "INNER JOIN flw_his_task ht ON hta.task_id = ht.id " +
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
            "INNER JOIN flw_task t ON ta.task_id = t.id " +
            "INNER JOIN flw_his_instance hi ON t.instance_id = hi.id " +
            "LEFT JOIN flw_ext_instance ei ON t.instance_id = ei.id " +
            "LEFT JOIN (" +
            "  SELECT instance_id, finish_time, id " +
            "  FROM flw_his_task " +
            "  WHERE parent_task_id = 0" +
            ") ht ON ta.instance_id = ht.instance_id " +
            "LEFT JOIN flw_his_task_actor hta ON ht.id = hta.task_id " +
            "WHERE ta.actor_id = #{userId} " +
            "  AND t.task_type = 1 " +
            "<if test='tenantId != null'> AND t.tenant_id = #{tenantId} </if>" +
            "ORDER BY t.create_time DESC" +
            "</script>")
    IPage<TodoListVO> todoList(@Param("userId") String userId, @Param("tenantId") String tenantId, Page page);

    @Select("<script>" +
            "SELECT" +
            "  ei.id AS instanceId," +
            "  a.task_id, ei.process_name," +
            "  start_actor.actor_name AS startName, " +
            "  b.task_name AS currentNode, " +
            "  b.create_time AS startTime, " +
            "  b.finish_time, b.duration, b.task_state " +
            "FROM flw_his_task_actor a " +
            "INNER JOIN flw_his_task b ON a.task_id = b.id " +
            "LEFT JOIN flw_ext_instance ei ON b.instance_id = ei.id " +
            "LEFT JOIN (" +
            "  SELECT ht.instance_id, hta.actor_name " +
            "  FROM flw_his_task ht " +
            "  JOIN flw_his_task_actor hta ON ht.id = hta.task_id " +
            "  WHERE ht.parent_task_id = 0 " +
            "  GROUP BY ht.instance_id, hta.actor_name" +
            ") start_actor ON b.instance_id = start_actor.instance_id " +
            "WHERE a.actor_id = #{userId} " +
            "  AND b.task_type != 0 " +
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
            "        WHEN hi.end_time IS NOT NULL THEN task_sum.total_duration" +
            "        ELSE TIMESTAMPDIFF(SECOND, ht.create_time, NOW()) * 1000" +
            "    END AS duration " +
            "FROM flw_his_task ht " +
            "INNER JOIN flw_his_task_actor hta ON ht.id = hta.task_id " +
            "INNER JOIN flw_his_instance hi ON ht.instance_id = hi.id " +
            "LEFT JOIN flw_ext_instance ei ON ht.instance_id = ei.id " +
            "LEFT JOIN (" +
            "  SELECT instance_id, SUM(duration) as total_duration " +
            "  FROM flw_his_task " +
            "  GROUP BY instance_id" +
            ") task_sum ON hi.id = task_sum.instance_id " +
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
            "  start_actor.actor_name AS startName, " +
            "  hi.create_time AS submitTime, " +
            "  b.task_name AS currentNode, " +
            "  hi.instance_state AS taskState, " +
            "  CASE " +
            "    WHEN hi.end_time IS NOT NULL THEN task_sum.total_duration " +
            "    ELSE TIMESTAMPDIFF(SECOND, hi.create_time, NOW()) * 1000 " +
            "  END AS duration, " +
            "  b.finish_time AS endTime " +
            "FROM flw_his_task_actor a " +
            "INNER JOIN flw_his_task b ON a.task_id = b.id " +
            "INNER JOIN flw_his_instance hi ON b.instance_id = hi.id " +
            "LEFT JOIN flw_ext_instance ei ON b.instance_id = ei.id " +
            "LEFT JOIN (" +
            "  SELECT instance_id, SUM(duration) as total_duration " +
            "  FROM flw_his_task " +
            "  GROUP BY instance_id" +
            ") task_sum ON hi.id = task_sum.instance_id " +
            "LEFT JOIN (" +
            "  SELECT ht.instance_id, hta.actor_name " +
            "  FROM flw_his_task ht " +
            "  JOIN flw_his_task_actor hta ON ht.id = hta.task_id " +
            "  WHERE ht.parent_task_id = 0 " +
            "  GROUP BY ht.instance_id, hta.actor_name" +
            ") start_actor ON b.instance_id = start_actor.instance_id " +
            "WHERE a.actor_id = #{userId} " +
            "  AND a.weight = 6 " +
            "<if test='tenantId != null'> AND hi.tenant_id = #{tenantId} </if>" +
            "ORDER BY hi.create_time DESC" +
            "</script>")
    IPage<AboutListVO> aboutList(@Param("userId") String userId, @Param("tenantId") String tenantId, Page page);

}
