package com.wf.mapper;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.wf.entity.AboutListVO;
import com.wf.entity.DoneListVO;
import com.wf.entity.SubmitListVO;
import com.wf.entity.TodoListVO;
import org.apache.ibatis.annotations.*;

import java.util.List;
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
            "    (SELECT COUNT(DISTINCT t.id) " +
            "     FROM flw_task t " +
            "     INNER JOIN flw_task_actor ta ON t.id = ta.task_id " +
            "     WHERE ta.actor_id = #{userId} " +
            "       AND t.task_type = 1 " +
            "       <if test='tenantId != null'> AND ta.tenant_id = #{tenantId} </if> " +
            "    ) AS todo, " +
            "    COALESCE(SUM(CASE WHEN ht.task_type NOT IN (0, 2, 25) THEN 1 ELSE 0 END), 0) AS done, " +
            "    COALESCE(SUM(CASE WHEN ht.perform_type = 0 THEN 1 ELSE 0 END), 0) AS submit, " +
            "    COALESCE(SUM(CASE WHEN hta.weight = 6 THEN 1 ELSE 0 END), 0) AS about " +
            "FROM flw_his_task_actor hta " +
            "RIGHT JOIN flw_his_task ht ON hta.task_id = ht.id " +
            "WHERE 1=1 " +
            "   <if test='tenantId != null'> AND (hta.tenant_id = #{tenantId} OR hta.tenant_id IS NULL) </if>" +
            "</script>")
    Map<String, Long> taskCount(@Param("userId") String userId, @Param("tenantId") String tenantId);

    @Select("<script>" +
            "SELECT " +
            "    hi.id AS instanceId, " +
            "    t.id AS taskId, " +
            "    COALESCE(ei.process_name, p.process_name) AS process_name, " +
            "    start_actor.actor_name AS startName, " +
            "    ht.finish_time AS submitTime, " +
            "    t.task_name AS currentNode, " +
            "    t.create_time AS arriveTime, " +
            "    hi.instance_state AS taskState " +
            "FROM flw_task t " +
            "INNER JOIN flw_task_actor ta ON t.id = ta.task_id " +
            "INNER JOIN flw_instance i ON t.instance_id = i.id " +
            "LEFT JOIN flw_process p ON i.process_id = p.id " +
            "LEFT JOIN flw_his_instance hi ON i.id = hi.id " +
            "LEFT JOIN flw_ext_instance ei ON i.id = ei.id " +
            "LEFT JOIN ( " +
            "    SELECT hta.instance_id, hta.actor_name  " +
            "    FROM flw_his_task ht " +
            "    INNER JOIN flw_his_task_actor hta ON ht.id = hta.task_id " +
            "    WHERE ht.parent_task_id = 0 " +
            ") start_actor ON i.id = start_actor.instance_id " +
            "LEFT JOIN flw_his_task ht ON ht.instance_id = i.id AND ht.parent_task_id = 0 " +
            "WHERE ta.actor_id = #{userId} " +
            "  AND t.task_type = 1 " +
            "  <if test='tenantId != null'> AND t.tenant_id = #{tenantId} </if> " +
            "ORDER BY t.create_time DESC" +
            "</script>")
    IPage<TodoListVO> todoList(@Param("userId") String userId, @Param("tenantId") String tenantId, Page page);

    @Select("<script>" +
            "SELECT " +
            "    ei.id AS instanceId, " +
            "    a.task_id, " +
            "    ei.process_name, " +
            "    MAX(start_actor.actor_name) AS startName, " +
            "    b.task_name AS currentNode, " +
            "    MIN(b.create_time) AS startTime, " +
            "    MAX(b.finish_time) AS finishTime, " +
            "    SUM(b.duration) AS duration, " +
            "    b.task_state " +
            "FROM flw_his_task_actor a " +
            "INNER JOIN flw_his_task b ON a.task_id = b.id " +
            "LEFT JOIN flw_ext_instance ei ON b.instance_id = ei.id " +
            "LEFT JOIN ( " +
            "    SELECT ht.instance_id, hta.actor_name " +
            "    FROM flw_his_task ht " +
            "    INNER JOIN flw_his_task_actor hta ON ht.id = hta.task_id " +
            "    WHERE ht.parent_task_id = 0 " +
            ") start_actor ON b.instance_id = start_actor.instance_id " +
            "WHERE a.actor_id = #{userId} " +
            "  AND b.task_type NOT IN (0, 2, 25) " +
            "  <if test='tenantId != null'> AND b.tenant_id = #{tenantId} </if> " +
            "GROUP BY ei.id, a.task_id, ei.process_name, b.task_name, b.task_state " +
            "ORDER BY MAX(b.create_time) DESC" +
            "</script>")
    IPage<DoneListVO> doneList(@Param("userId") String userId, @Param("tenantId") String tenantId, Page page);

    @Select("<script>" +
            "SELECT " +
            "    hi.id AS instanceId, " +
            "    ht.id AS taskId, " +
            "    ei.process_name, " +
            "    hta.actor_name AS startName, " +
            "    hi.create_time AS submitTime, " +
            "    hi.end_time AS endTime, " +
            "    hi.current_node_name AS currentNode, " +
            "    hi.instance_state AS taskState, " +
            "    COALESCE( " +
            "        task_sum.total_duration, " +
            "        TIMESTAMPDIFF(SECOND, hi.create_time, COALESCE(hi.end_time, NOW())) * 1000 " +
            "    ) AS duration " +
            "FROM flw_his_task ht " +
            "INNER JOIN flw_his_task_actor hta ON ht.id = hta.task_id " +
            "INNER JOIN flw_his_instance hi ON ht.instance_id = hi.id " +
            "LEFT JOIN flw_ext_instance ei ON ht.instance_id = ei.id " +
            "LEFT JOIN ( " +
            "    SELECT instance_id, SUM(duration) AS total_duration " +
            "    FROM flw_his_task " +
            "    GROUP BY instance_id " +
            ") task_sum ON hi.id = task_sum.instance_id " +
            "WHERE ht.parent_task_id = '0' " +  // 修正点：确保类型匹配
            "  <if test='userId != null'> " +
            "      AND hta.actor_id = #{userId} " +
            "  </if> " +
            "  <if test='tenantId != null'> " +
            "      AND hi.tenant_id = #{tenantId} " +
            "  </if> " +
            "ORDER BY hi.create_time DESC" +
            "</script>")
    IPage<SubmitListVO> submitList(@Param("userId") String userId, @Param("tenantId") String tenantId, Page<SubmitListVO> page);

    @Select("<script>" +
            "SELECT " +
            "    hi.id AS instanceId, " +
            "    a.task_id, " +
            "    ei.process_name, " +
            "    start_actor.actor_name AS startName, " +
            "    hi.create_time AS submitTime, " +
            "    b.task_name AS currentNode, " +
            "    hi.instance_state AS taskState, " +
            "    COALESCE(task_sum.total_duration,  " +
            "             TIMESTAMPDIFF(SECOND, hi.create_time, COALESCE(hi.end_time, NOW())) * 1000) AS duration, " +
            "    b.finish_time AS endTime " +
            "FROM flw_his_task_actor a " +
            "INNER JOIN flw_his_task b ON a.task_id = b.id " +
            "INNER JOIN flw_his_instance hi ON b.instance_id = hi.id " +
            "LEFT JOIN flw_ext_instance ei ON b.instance_id = ei.id " +
            "LEFT JOIN ( " +
            "    SELECT instance_id, SUM(duration) AS total_duration " +
            "    FROM flw_his_task " +
            "    GROUP BY instance_id " +
            ") task_sum ON hi.id = task_sum.instance_id " +
            "LEFT JOIN ( " +
            "    SELECT ht.instance_id, hta.actor_name " +
            "    FROM flw_his_task ht " +
            "    INNER JOIN flw_his_task_actor hta ON ht.id = hta.task_id " +
            "    WHERE ht.parent_task_id = 0 " +
            ") start_actor ON b.instance_id = start_actor.instance_id " +
            "WHERE a.actor_id = #{userId} " +
            "  AND a.weight = 6 " +
            "  <if test='tenantId != null'> AND hi.tenant_id = #{tenantId} </if> " +
            "ORDER BY hi.create_time DESC" +
            "</script>")
    IPage<AboutListVO> aboutList(@Param("userId") String userId, @Param("tenantId") String tenantId, Page page);


    @Select("<script>" +
            "SELECT DISTINCT business_key " +
            "FROM ( " +
            "    SELECT hi.business_key " +
            "    FROM flw_his_instance hi " +
            "    INNER JOIN flw_his_task_actor hta ON hi.id = hta.instance_id " +
            "    WHERE hta.actor_id = #{userId} " +
            "    <if test='tenantId != null'> AND hi.tenant_id = #{tenantId} </if> " +
            "    UNION " +
            "    SELECT i.business_key " +
            "    FROM flw_instance i " +
            "    INNER JOIN flw_task_actor ta ON i.id = ta.instance_id " +
            "    WHERE ta.actor_id = #{userId} " +
            "    <if test='tenantId != null'> AND i.tenant_id = #{tenantId} </if> " +
            ") AS combined " +
            "</script>")
    List<String> getBusinessKeys(@Param("userId") String userId, @Param("tenantId") String tenantId);

}
